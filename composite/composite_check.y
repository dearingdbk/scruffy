/*
 * File: composite_check.y
 * Author: Bruce Dearing 100036623
 * Date: 2013/10/27
 * Version: 1.1
 *
 * Purpose: ANSI C Yacc grammar, to parse tokens received from the
 *          flex scanner composite_check.l
 *          Grammar has been re-written to identify common style errors
 *          present in C code and alert the user.
 *
 * Mods:    2014/09/01 Jim Diamond.  Remove some compiler warnings,
 *          do a bit of reformatting.
 */

%locations
%glr-parser
%expect 2
%expect-rr 0

%{

/* START Include files. */
#ifndef COMPOSITE_CHECK_TAB_H
    #define COMPOSITE_CHECK_TAB_H
    #include "composite_check.tab.h"
#endif
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "../functions/functions.h"
/* END Include files. */

/* START Program variables */
extern char *yytext;
/* End Program variables */


/* START Definitions. */
#define YYERROR_VERBOSE
#define MAX_TRYS	1000
#define MULTI_DEF	"Variable initialized in a multi-variable declaration."
#define ES 		"Empty statement."
#define ECB 		"Empty code block."
#define DCL 		"\"default\" case should appear after all " \
			"the cases in a switch statement."
#define SWD		"switch without a \"default\" case."
#define NEBC		"Do not include executable statements before " \
			"the first case label."
#define MBS		"Missing Break statement."
#define LCC		"Array initialization contains optional trailing comma."
/* End Definitions. */

/* START Function Definitions */
void yyerror(const char * str);
/* START Function Definitions */

%}

%token        BIDENTIFIER IDENTIFIER I_CONSTANT F_CONSTANT
%token	      STRING_LITERAL FUNC_NAME SIZEOF
%token        PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token        AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token        SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token        XOR_ASSIGN OR_ASSIGN
%token        TYPEDEF_NAME ENUMERATION_CONSTANT

%token        TYPEDEF EXTERN STATIC AUTO REGISTER INLINE
%token        CONST RESTRICT VOLATILE
%token        BOOL CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE VOID
%token        COMPLEX IMAGINARY
%token        STRUCT UNION ENUM ELLIPSIS

%token        CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%token        ALIGNAS ALIGNOF ATOMIC GENERIC NORETURN STATIC_ASSERT THREAD_LOCAL

%start translation_unit
%%

primary_expression
    : IDENTIFIER
    | constant  { if (atoi(yytext) > 2)
                  {
                     print_magic_number(yylloc.first_line, 
                     yylloc.last_column, yytext); 
                  }
                }
    | string
    | '(' expression ')'
    | generic_selection
    ;

constant
    : I_CONSTANT               /* includes character_constant */
    | F_CONSTANT
    | ENUMERATION_CONSTANT     /* after it has been defined as such */
    ;

enumeration_constant           /* before it has been defined as such */
    : IDENTIFIER
    ;

string
    : STRING_LITERAL
    | FUNC_NAME
    ;

generic_selection
    : GENERIC '(' assignment_expression ',' generic_assoc_list ')'
    ;

generic_assoc_list
    : generic_association
    | generic_assoc_list ',' generic_association
    ;

generic_association
    : type_name ':' assignment_expression
    | DEFAULT ':' assignment_expression
    ;

postfix_expression
    : primary_expression
    | postfix_expression '[' expression ']'
    | postfix_expression '(' ')'
    | postfix_expression '(' argument_expression_list ')'
    | postfix_expression '.' IDENTIFIER
    | postfix_expression PTR_OP IDENTIFIER
    | postfix_expression INC_OP
    | postfix_expression DEC_OP
    | '(' type_name ')' '{' initializer_list '}'
    | '(' type_name ')' '{' initializer_list ',' '}'
    ;

argument_expression_list
    : assignment_expression
    | argument_expression_list ',' assignment_expression
    ;

unary_expression
    : postfix_expression
    | INC_OP unary_expression
    | DEC_OP unary_expression
    | unary_operator cast_expression
    | SIZEOF unary_expression
    | SIZEOF '(' type_name ')'
    | ALIGNOF '(' type_name ')'
    ;

unary_operator
    : '&'
    | '*'
    | '+'
    | '-'
    | '~'
    | '!'
    ;

cast_expression
    : unary_expression
    | '(' type_name ')' cast_expression
    ;

multiplicative_expression
    : cast_expression
    | multiplicative_expression '*' cast_expression
    | multiplicative_expression '/' cast_expression
    | multiplicative_expression '%' cast_expression
    ;

additive_expression
    : multiplicative_expression
    | additive_expression '+' multiplicative_expression
    | additive_expression '-' multiplicative_expression
    ;

shift_expression
    : additive_expression
    | shift_expression LEFT_OP additive_expression
    | shift_expression RIGHT_OP additive_expression
    ;

relational_expression
    : shift_expression
    | relational_expression '<' shift_expression
    | relational_expression '>' shift_expression
    | relational_expression LE_OP shift_expression
    | relational_expression GE_OP shift_expression
    ;

equality_expression
    : relational_expression
    | equality_expression EQ_OP relational_expression
    | equality_expression NE_OP relational_expression
    ;

and_expression
    : equality_expression
    | and_expression '&' equality_expression
    ;

exclusive_or_expression
    : and_expression
    | exclusive_or_expression '^' and_expression
    ;

inclusive_or_expression
    : exclusive_or_expression
    | inclusive_or_expression '|' exclusive_or_expression
    ;

logical_and_expression
    : inclusive_or_expression
    | logical_and_expression AND_OP inclusive_or_expression
    ;

logical_or_expression
    : logical_and_expression
    | logical_or_expression OR_OP logical_and_expression
    ;

conditional_expression
    : logical_or_expression
    | logical_or_expression '?' expression ':' conditional_expression
    ;

assignment_expression
    : conditional_expression
    | unary_expression assignment_operator assignment_expression
    ;

assignment_operator
    : '='
    | MUL_ASSIGN
    | DIV_ASSIGN
    | MOD_ASSIGN
    | ADD_ASSIGN
    | SUB_ASSIGN
    | LEFT_ASSIGN
    | RIGHT_ASSIGN
    | AND_ASSIGN
    | XOR_ASSIGN
    | OR_ASSIGN
    ;

expression
    : assignment_expression
    | expression ',' assignment_expression
    ;

constant_expression
    : conditional_expression        /* with constraints */
    ;

declaration
    : declaration_specifiers ';'
    | declaration_specifiers init_declarator_list ';'
    | static_assert_declaration
    ;

declaration_specifiers
    : storage_class_specifier declaration_specifiers
    | storage_class_specifier
    | type_specifier declaration_specifiers
    | type_specifier
    | type_qualifier declaration_specifiers
    | type_qualifier
    | function_specifier declaration_specifiers
    | function_specifier
    | alignment_specifier declaration_specifiers
    | alignment_specifier
    ;

/*
 * CHANGE OF MULTI_DECLARATION GRAMMAR
 */

init_declarator_list
    : init_declarator
    | multi_declarator_list ',' multi_declarator
    ;

multi_declarator_list
    : multi_declarator
    | multi_declarator_list ',' multi_declarator
    ;

multi_declarator
    : declarator '=' initializer { print_msg(yylloc.first_line, 
                                     yylloc.last_column - 1, MULTI_DEF); }
    | declarator
    ;
/*
 * END CHANGE OF MULTI_DECLARATION GRAMMAR
 */

init_declarator
    : declarator '=' initializer
    | declarator
    ;

storage_class_specifier
    : TYPEDEF        /* identifiers must be flagged as TYPEDEF_NAME */
    | EXTERN
    | STATIC
    | THREAD_LOCAL
    | AUTO
    | REGISTER
    ;

type_specifier
    : VOID
    | CHAR
    | SHORT
    | INT
    | LONG
    | FLOAT
    | DOUBLE
    | SIGNED
    | UNSIGNED
    | BOOL
    | COMPLEX
    | IMAGINARY                 /* non-mandated extension */
    | atomic_type_specifier
    | struct_or_union_specifier
    | enum_specifier
    | TYPEDEF_NAME             /* after it has been defined as such */
    ;

struct_or_union_specifier
    : struct_or_union '{' struct_declaration_list '}'
    | struct_or_union IDENTIFIER '{' struct_declaration_list '}'
    | struct_or_union IDENTIFIER
    ;

struct_or_union
    : STRUCT
    | UNION
    ;

struct_declaration_list
    : struct_declaration
    | struct_declaration_list struct_declaration
    ;

struct_declaration
    : specifier_qualifier_list ';'     /* for anonymous struct/union */
    | specifier_qualifier_list struct_declarator_list ';'
    | static_assert_declaration
    ;

specifier_qualifier_list
    : type_specifier specifier_qualifier_list
    | type_specifier
    | type_qualifier specifier_qualifier_list
    | type_qualifier
    ;

struct_declarator_list
    : struct_declarator
    | struct_declarator_list ',' struct_declarator
    ;

struct_declarator
    : ':' constant_expression
    | declarator ':' constant_expression
    | declarator
    ;

enum_specifier
    : ENUM '{' enumerator_list '}'
    | ENUM '{' enumerator_list ',' '}'
    | ENUM IDENTIFIER '{' enumerator_list '}'
    | ENUM IDENTIFIER '{' enumerator_list ',' '}'
    | ENUM IDENTIFIER
    ;

enumerator_list
    : enumerator
    | enumerator_list ',' enumerator
    ;

enumerator    /* identifiers must be flagged as ENUMERATION_CONSTANT */
    : enumeration_constant '=' constant_expression
    | enumeration_constant
    ;

atomic_type_specifier
    : ATOMIC '(' type_name ')'
    ;

type_qualifier
    : CONST
    | RESTRICT
    | VOLATILE
    | ATOMIC
    ;

function_specifier
    : INLINE
    | NORETURN
    ;

alignment_specifier
    : ALIGNAS '(' type_name ')'
    | ALIGNAS '(' constant_expression ')'
    ;

declarator
    : pointer direct_declarator
    | direct_declarator
    ;

direct_declarator
    : IDENTIFIER { if (isupper(yytext[0]) || isdigit(yytext[0]))
                   {
                      
                      print_bad_ident(yylloc.first_line,
                         yylloc.last_column, yytext);
                   }
                 }
    | '(' declarator ')'
    | direct_declarator '[' ']'
    | direct_declarator '[' '*' ']'
    | direct_declarator '[' STATIC type_qualifier_list assignment_expression ']'
    | direct_declarator '[' STATIC assignment_expression ']'
    | direct_declarator '[' type_qualifier_list '*' ']'
    | direct_declarator '[' type_qualifier_list STATIC assignment_expression ']'
    | direct_declarator '[' type_qualifier_list assignment_expression ']'
    | direct_declarator '[' type_qualifier_list ']'
    | direct_declarator '[' assignment_expression ']'
    | direct_declarator '(' parameter_type_list ')'
    | direct_declarator '(' ')'
    | direct_declarator '(' identifier_list ')'
    ;

pointer
    : '*' type_qualifier_list pointer
    | '*' type_qualifier_list
    | '*' pointer
    | '*'
    ;

type_qualifier_list
    : type_qualifier
    | type_qualifier_list type_qualifier
    ;


parameter_type_list
    : parameter_list ',' ELLIPSIS
    | parameter_list
    ;

parameter_list
    : parameter_declaration
    | parameter_list ',' parameter_declaration
    ;

parameter_declaration
    : declaration_specifiers declarator
    | declaration_specifiers abstract_declarator
    | declaration_specifiers
    ;

identifier_list
    : IDENTIFIER
    | identifier_list ',' IDENTIFIER
    ;

type_name
    : specifier_qualifier_list abstract_declarator
    | specifier_qualifier_list
    ;

abstract_declarator
    : pointer direct_abstract_declarator
    | pointer
    | direct_abstract_declarator
    ;

direct_abstract_declarator
    : '(' abstract_declarator ')'
    | '[' ']'
    | '[' '*' ']'
    | '[' STATIC type_qualifier_list assignment_expression ']'
    | '[' STATIC assignment_expression ']'
    | '[' type_qualifier_list STATIC assignment_expression ']'
    | '[' type_qualifier_list assignment_expression ']'
    | '[' type_qualifier_list ']'
    | '[' assignment_expression ']'
    | direct_abstract_declarator '[' ']'
    | direct_abstract_declarator '[' '*' ']'
    | direct_abstract_declarator '[' STATIC type_qualifier_list assignment_expression ']'
    | direct_abstract_declarator '[' STATIC assignment_expression ']'
    | direct_abstract_declarator '[' type_qualifier_list assignment_expression ']'
    | direct_abstract_declarator '[' type_qualifier_list STATIC assignment_expression ']'
    | direct_abstract_declarator '[' type_qualifier_list ']'
    | direct_abstract_declarator '[' assignment_expression ']'
    | '(' ')'
    | '(' parameter_type_list ')'
    | direct_abstract_declarator '(' ')'
    | direct_abstract_declarator '(' parameter_type_list ')'
    ;

/* CHECK FOR OPTIONAL , AT END OF INITIALIZER LIST  */

initializer
    : '{' initializer_list '}'
    | '{' initializer_list ',' '}' { print_msg(yylloc.first_line, yylloc.last_column - 1, LCC );}
    | assignment_expression
    ;

initializer_list
    : designation initializer
    | initializer
    | initializer_list ',' designation initializer
    | initializer_list ',' initializer
    ;

designation
    : designator_list '='
    ;

designator_list
    : designator
    | designator_list designator
    ;

designator
    : '[' constant_expression ']'
    | '.' IDENTIFIER
    ;

static_assert_declaration
    : STATIC_ASSERT '(' constant_expression ',' STRING_LITERAL ')' ';'
    ;

statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    | jump_statement
    ;

labeled_statement
    : IDENTIFIER ':' statement
    ;

/*
 * CHANGE OF COMPOUND STATEMENT GRAMMAR
 */

compound_statement
    : '{' '}' {print_msg(yylloc.first_line, 0, ECB);}
    | '{' block_item_list '}'
    ;

/*
 * END CHANGE OF COMPOUND STATEMENT GRAMMAR
 */

block_item_list
    : block_item
    | block_item_list block_item
    ;

block_item
    : declaration
    | statement
    ;

/*
 * CHANGE OF EXPRESSION_STATEMENT GRAMMAR
 */

expression_statement
    : ';' { print_msg(yylloc.first_line, yylloc.last_column - 1, ES); }
    | expression ';'
    ;

for_expression_statement
    : ';'
    | expression ';'
    ;

/*
 * END CHANGE OF EXPRESSION_STATEMENT GRAMMAR
 */


/*
 * CHANGE OF SELECTION_STATEMENT GRAMMAR.
 */

selection_statement
    : IF '(' expression ')' statement ELSE statement
    | IF '(' expression ')' statement
    | SWITCH '(' expression ')' '{' switch_block '}'
    ;

switch_block
    : switch_stmts switch_cases
    | error /* Catches acceptible code error executable statements at switch end */
    ;

switch_cases
    : case_block switch_end
    | switch_end
    ;

case_after_default
    : case_block { print_msg(yylloc.first_line, 0, DCL);}
    |
    ;

switch_end
    : default_block case_after_default
    | { print_msg(yylloc.first_line, 0, SWD); }
    ;

 /*
  * According to the ISO C Standard,
  * ISO/IEC 9899:201x
  * subclause 6.8.4.2 paragraph 4
  */
switch_stmts
    : stmts { print_msg(yylloc.first_line, 0, NEBC); }
    |
    ;

stmts
    : s_item
    | stmts s_item
    ;

s_item
    : declaration
    | switch_statement
    ;

switch_statement
    : labeled_statement
    | compound_statement
    | expression_statement
    | selection_statement
    | iteration_statement
    ;


case_block
    : CASE constant_expression ':' case_stmts case_end
    | case_block CASE constant_expression ':' case_stmts case_end
    ;

case_end
    : GOTO IDENTIFIER ';'
    | CONTINUE ';'
    | BREAK ';'
    | RETURN ';'
    | RETURN expression ';'
    | { print_msg(yylloc.first_line, 0, MBS); }
    ;

default_block
    : DEFAULT ':' case_stmts case_end
    ;

case_stmts
    : stmts
    |
    ;

/*
 * END CHANGE OF SELECTION_STATEMENT GRAMMAR
 */

/*
 * CHANGE OF ITERATION STATEMENT GRAMMAR.
 */

iteration_statement
    : WHILE '(' expression ')' statement
    | DO statement WHILE '(' expression ')' ';'
    | FOR '(' for_expression_statement for_expression_statement ')' statement
    | FOR '(' for_expression_statement for_expression_statement expression ')' statement
    | FOR '(' declaration for_expression_statement ')' statement
    | FOR '(' declaration for_expression_statement expression ')' statement
    ;

/*
 * END CHANGE OF ITERATION STATEMENT GRAMMAR.
 */

jump_statement
    : GOTO IDENTIFIER ';'
    | CONTINUE ';'
    | BREAK ';'
    | RETURN ';'
    | RETURN expression ';'
    ;

translation_unit
    : external_declaration
    | translation_unit external_declaration
    ;

external_declaration
    : function_definition
    | declaration
    ;

function_definition
    : declaration_specifiers declarator declaration_list compound_statement
    | declaration_specifiers declarator compound_statement

declaration_list
    : declaration
    | declaration_list declaration
    ;

%%



/*      
 * Name:        yyerror 
 * Purpose:     function called to report errors when check_comments is 
 *              unable to parse received tokens.
 * Arguments:   str ~ the string containing the received error message.
 * Output:      prints to stdout
 * Modifies:    none
 * Returns:     1
 * Assumptions: 
 * Bugs:        
 * Notes:
 */

void 
yyerror(const char * str)
{
   /*
    * Purposely do nothing here, we want to error quietly
    * to allow greater flexibility within this parser.
    */
}


/*
 * Name:        main
 * Purpose:     calls yyparse() to parse tokens.
 * Arguments:   none.
 * Output:      none.
 * Modifies:    none.
 * Returns:     void.
 * Assumptions: 
 * Bugs:        none to date.
 * Notes:
 */

int
main()
{
    /*
     * The parser returns a value of zero if the parse succeeds
     * and nonzero if the parse fails.
     * Here we continue parsing even on error up to
     * MAX_TRYS.
     */

    int errors = 0;

    while (errors < MAX_TRYS)
    {
	if (yyparse())
	    errors++;
	else
	    break;
    }

    return errors;
}
