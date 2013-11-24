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

void check_header();
void check_function();
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

unsigned int header[LAST_VAL] = {0};
unsigned int function[LAST_VAL] = {0};

%}
%token  IDENTIFIER FILE_LBL AUTHOR START_COMMENT END_COMMENT VERSION DATE PURPOSE 
%token	NAME ARGUMENTS OUTPUT MODIFIES RETURNS ASSUMPTIONS BUGS NOTES 
%token  LAST_VAL
%start program_body
%%

program_body
    : program_start program_comments
    ;

program_comments
    : comment_start
    | program_comments comment_start
    ;

program_start
    : START_COMMENT header_comment END_COMMENT {check_header();}
    | error
    ;

comment_start
    : START_COMMENT comment_body END_COMMENT 

comment_body
    : function_comment  { check_function(); } 
    | /* regular comments */ 
    ;

header_comment
    : header_list 
    ;

function_comment
    : function_list
    ;

function_list
    : function_label_name colon
    | function_list function_label_name colon
    ;

function_label_name
    : NAME        { function[NAME] = 1; }
    | PURPOSE     { function[PURPOSE] = 1; }
    | ARGUMENTS   { function[ARGUMENTS] = 1; }
    | OUTPUT      { function[OUTPUT] = 1; }
    | MODIFIES    { function[MODIFIES] = 1; }
    | RETURNS     { function[RETURNS] = 1; }
    | ASSUMPTIONS { function[ASSUMPTIONS] = 1; }
    | BUGS        { function[BUGS] = 1; }
    | NOTES       { function[NOTES] = 1; }
    ;


header_list
    : header_label_name colon
    | header_list header_label_name colon
    ;

header_label_name
    : FILE_LBL  {header[FILE_LBL] = 1;}
    | AUTHOR    {header[AUTHOR] = 1;}
    | VERSION   {header[VERSION] = 1;}
    | DATE      {header[DATE] = 1;}
    | PURPOSE   {header[PURPOSE] = 1;}
    ;

colon
    : ':'
    |
    ;
%%   


void check_header()
{
    static unsigned int mask[] = {1, 2, 4, 8, 16, 32};
    int i = 1;
    int k;
        
    i = (i << 1) | header[FILE_LBL];
    i = (i << 1) | header[AUTHOR];
    i = (i << 1) | header[DATE];
    i = (i << 1) | header[VERSION];
    i = (i << 1) | header[PURPOSE];
   
    for (k = 0; k < 5; k++)
    {
        if ((i & mask[k]) == 0)
        {
            switch(k)
            {
              case 0:
                printf("Missing Purpose\n");
                break;
              case 1:
                printf("Missing Version\n");
                break;
              case 2:
                printf("Missing Date\n");
                break;
              case 3:
                printf("Missing Author\n");
                break;
              case 4:
                printf("Missing File name from header comment.\n");
                break;
              default:
               break;
            }
        }    
    }

}


void check_function()
{
    static unsigned int mask[] = {256, 128, 64, 32, 16, 8, 4, 2, 1};
    int i = 1;
    int k;

    i = (i << 1) | function[NAME];
    i = (i << 1) | function[PURPOSE];
    i = (i << 1) | function[ARGUMENTS];
    i = (i << 1) | function[OUTPUT];
    i = (i << 1) | function[MODIFIES];
    i = (i << 1) | function[RETURNS];
    i = (i << 1) | function[ASSUMPTIONS];
    i = (i << 1) | function[BUGS];
    i = (i << 1) | function[NOTES];

    for (k = 0; k < 9; k++)
    {
        if ((i & mask[k]) == 0)
        {
            switch(k)
            {
              case 0:
                printf("Missing function comment name.\n");
                break;
              case 1:
                printf("Missing function comment purpose.\n");
                break;
              case 2:
                printf("Missing function comment arguments.\n");
                break;
              case 3:
                printf("Missing function comment output\n");
                break; 
              case 4:
                printf("Missing function comment modifies.\n");
                break;
              case 5:
                printf("Missing function comment returns. \n");
                break;
              case 6:
                printf("Missing function comment assumptions. \n");
                break;
                case 7:
                printf("Missing function comment Bugs. \n");
                break;
                case 8:
                printf("Missing function comment Notes. \n");
                break;
              default:
                break;
            }
        }
    }
}

