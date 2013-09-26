/** ANSI C Yacc grammar 
*   YACC file for ANSI C grammar
*
*/
%locations
%{

#include <stdio.h>
#include "check_indent.tab.h"

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
