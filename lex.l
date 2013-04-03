%{

/*
 * File:     lex.l
 * Author:   BD
 * Date:     2012/21/11
 * Version:  1.0
 *
 * Purpose:  Lex Program to read in ACSII text and produce tokens 
 *           to supply to the yacc parser.
 * 
 */
 
#include "y.tab.h"
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
%}
%option yylineno
%%
<<EOF>>                return DONE;
begin                 return BEG;
end                   return END;
read                  return READ;
write                 return WRITE;
\:                    return COLON;
\;                    return SEMI;
\,                    return COMMA;
\=                    return EQUAL;
\(                    return LPAR;
\)                    return RPAR;
\+                    return PLUS;
\-                    return MINUS;
[0-9]+                return INTLIT;
[a-z][a-zA-Z0-9]*     return ID;
\n                      /* ignore EOL */;
[ \t]+                  /* ignore whitespace */;
.                     return (int) yytext[0];;
%%

