/** ANSI C Yacc grammar 
*   YACC file for ANSI C grammar
*
*/
%locations
%{

#include <stdio.h>
#ifndef CHECK_INDENT_TAB_H
#define CHECK_INDENT_TAB_H
#include "check_indent.tab.h"
#endif

void yyerror(const char *s)
{
  fprintf(stderr, "ERROR line %d: %s\n", yylloc.first_line, s);
}
%}


%token END	
%start begin
%%

begin
    : END
    ;
%%
