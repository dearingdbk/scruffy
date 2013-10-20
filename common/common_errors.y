/** ANSI C Yacc grammar 
*   YACC file for ANSI C grammar
*
*/
%locations
%{

#include <stdio.h>
#ifndef COMMON_ERRORS_TAB_H
#define COMMON_ERRORS_TAB_H
#include "common_errors.tab.h"
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
