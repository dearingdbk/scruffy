/**
*   ANSI C grammar, Lex specification
*/


%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117

WS  [ \t\v\f]

%{
/* START Function Definitions */
/* END Function Definitions */

/* START Include files. */
//#include "magic_num.tab.h"
#include "../functions/functions.h"
/* END Include files. */

/* START Definitions. */
#define YY_USER_ACTION yycolumn += yyleng;

#define RESET(x) x = 1
/* END Definitions. */

int yycolumn = 1;
int save_state;

%}

/*
 * Parser options
 *
 * yylineno: The %yylineno option tells flex to define an integer 
 *           variable called yylineno and to maintain the current line 
 *           line number in it. Eevery time the scanner reads a '\n',
 *           it increments yylineno, and if the scanner backs up over
 *           a '\n', it decrements it.
 */
%option yylineno

/* START Exclusive Start State definitions. */
%x COMMENT
%x INCLUDE
%x DEFINE
%x STRING
%x EAT
%x QUOTE
%x ARRAY
/* END Exclusive Start State definitions. */

/* START Inclusive Start State definitions. */
/* END Inclusive Start State definitions. */
%%

^"#"[ \t]*"include"     { BEGIN(INCLUDE); }
<INCLUDE>.
<INCLUDE>\n             { RESET(yycolumn); BEGIN(INITIAL); }

^"#"[ \t]*"define"      { BEGIN(DEFINE);}
<DEFINE>.|\n            
<DEFINE>[^\\]\n         { RESET(yycolumn);  BEGIN(INITIAL); }

"/*"                    { BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL);}
<COMMENT><<EOF>>        { printf("%d: Unterminated comment\n",yylineno); return EOF; }
<COMMENT>[^*\n]+|. 
<COMMENT>\n             { RESET(yycolumn); }

"//".*                  /* Eat up single line comments. */

^"#"[ \t]*"undef".*     |
^"#"[ \t]*"if".*        |
^"#"[ \t]*"elif".*      |
^"#"[ \t]*"else".*      |
^"#"[ \t]*"endif".*     |
^"#"[ \t]*"line".*      |
^"#"[ \t]*"error".*     |
^"#"[ \t]*"pragma".*    |
^"#"                    ;  /* Eat up preprocessor directives. */

"\""                    { BEGIN(STRING);}
"'"                     { BEGIN(QUOTE); }
<QUOTE>[^'\\\n]
<QUOTE>"\\"             { save_state = YY_START; BEGIN(EAT); }
<QUOTE>"'"              { BEGIN(INITIAL); }
<QUOTE>\n               { RESET(yycolumn); }
<STRING>[^\"\\\n]
<STRING>\n              { RESET(yycolumn); }
<STRING>"\\"            { save_state = YY_START; BEGIN(EAT); }
<STRING>"\""            { BEGIN(INITIAL); }

<EAT>.|\n               { if (yytext[0] == '\n')
                            {
                                RESET(yycolumn); 
                            }
                          BEGIN(save_state); }

"= {"                   { BEGIN(ARRAY); }

<ARRAY>(.|\n)
<ARRAY>"};"             { BEGIN(INITIAL); }

[0-9]+                  { if (atoi(yytext) > 2)
                          {
                              print_magic_number(yylineno, yycolumn, yytext);
                          }
                        }


{WS}				{ /* whitespace separates tokens */ }
\n.*                { append(yylineno, yytext, yyleng);
                      RESET(yycolumn);
                      yyless(1);
                    }
.					{ /* discard bad characters */ }


%%


 int yywrap(void)        /* called at end of input */
 {
    return 1;           /* terminate now */
 }

