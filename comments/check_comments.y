/** ANSI C Yacc grammar 
*   YACC file for ANSI C grammar
*
*/

/*
 * File: composite_check.y
 * Author: Bruce Dearing 100036623
 * Date: 2013/10/27
 * Version: 1.0
 *
 * Purpose: ANSI C Yacc grammar, to parse tokens received from the
 * flex scanner composite_check.l
 * Grammar has been re-written to identify common style errors
 * present in C code and alert the user.
 */

%locations
//%glr-parser
//%expect 2
//%expect-rr 0

%{

#ifndef CHECK_COMMENTS_TAB_H
    #define CHECK_COMMENTS_TAB_H
    #include "check_comments.tab.h"
#endif

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>


extern char *yytext;
#define YYERROR_VERBOSE


main()
{
  yyparse();
} 

void yyerror(const char *s, ...)
{
  //fprintf(stderr, "ERROR line %d: %s\n", yylloc.first_line, s);
    va_list ap;
      va_start(ap, s);

if(yylloc.first_line)
    {
        fprintf(stderr, "%d.%d-%d.%d: error: ", 
            yylloc.first_line, yylloc.first_column,
            yylloc.last_line, yylloc.last_column);
            vfprintf(stderr, s, ap);

fprintf(stderr, "\n");
printf("%s\n", yytext);
    }
}
/*void yyerror(const char *str)
{
*
 * Purposely do nothing here, we want to error quietly
 * to allow greater flexibility within this parser.
 *
}*/


%}
%token  IDENTIFIER FILE_LBL AUTHOR START_COMMENT END_COMMENT VERSION DATE PURPOSE 
%token	NAME ARGUMENTS OUTPUT MODIFIES RETURNS ASSUMPTIONS BUGS NOTES 
%token	AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token	SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token	XOR_ASSIGN OR_ASSIGN
%token	TYPEDEF_NAME ENUMERATION_CONSTANT

%token	TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token	CONST RESTRICT VOLATILE
%token	BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token	COMPLEX IMAGINARY 
%token	STRUCT UNION ENUM ELLIPSIS

%token	CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token	ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%start program_comments
%%

program_comments
    : comment_start
    | program_comments comment_start
    ;

comment_start
    : START_COMMENT comment_body END_COMMENT 

comment_body
    : header_comment {printf("header_comment\n");} 
    | function_comment {printf("function comment\n");}
    | /* regular comments */ {printf("regular old comment\n");}
    ;

header_comment
    : header_list 
    ;

function_comment
    : function_list
    ;

function_list
    : function_label_name ':'
    | function_list function_label_name ':'
    ;

function_label_name
    : NAME
    | PURPOSE
    | ARGUMENTS
    | OUTPUT
    | MODIFIES
    | RETURNS
    | ASSUMPTIONS
    | BUGS
    | NOTES
    ;


header_list
    : header_label_name
    | header_list header_label_name
    ;

header_label_name
    : FILE_LBL colon
    | AUTHOR  colon
    | VERSION colon
    | DATE colon
    | PURPOSE colon
    ;

colon
    : ':'
    |
    ;
%%   

