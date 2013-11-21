%{

int yycolumn = 0;
/* START Include files. */
#include <stdio.h>
/* END Include files. */

/* START Definitions. */
#define YY_USER_ACTION yycolumn += yyleng;

#define RESET(x) x = 0
#define FALSE 0
#define TRUE 1
#define MAX_STRING 1024
#include <string.h>
#include "../functions/functions.h"
void handle_conditional(char *str, int line);
%}

%option yylineno

%x COMMENT
%x DEFINE
%x STRING
%x INCLUDE
%%

^"#"[ \t]*"include".*      { BEGIN(INCLUDE); }
<INCLUDE>.
<INCLUDE>\n                { RESET(yycolumn);  BEGIN(INITIAL); }


^"#"[ \t]*"define"      { BEGIN(DEFINE);}
<DEFINE>.|\n
<DEFINE>[^\\]\n         { RESET(yycolumn); BEGIN(INITIAL); }


"/*"                    { BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL);}
<COMMENT><<EOF>>        { printf("%d: Unterminated comment\n",yylineno); 
                          return EOF;
                        }
<COMMENT>([^*]|\n)+|.

"//".*                        /* Eat up single line comments. */

^"#"[ \t]*"undef".*        |
^"#"[ \t]*"if".*           |
^"#"[ \t]*"elif".*         |
^"#"[ \t]*"else".*         |
^"#"[ \t]*"endif".*        |
^"#"[ \t]*"line".*         |
^"#"[ \t]*"error".*        |
^"#"[ \t]*"pragma".*       |
^"#"                       ; /* Eat up preprocessor directives. */


"//".*                  /* Eat up single line comments. */

^[ \t]*                 /* Eat up white space at the beginning of a line. */

"while"                 | 
"for"                   |
"if"                    { handle_conditional(yytext, yyleng); }

.*"struct"[^\n=]*"{"    {  printf("%d:\n\n\t%s\n\n'{' should be on a new line.\n\n",
                                  yylineno, trim(yytext));
                        }

\n                      { RESET(yycolumn); }

.                       /* Eat up bad charachters. */

%%
main(int argc, char **argv)
{
    yylex();
}

int yywrap(void) /* called at end of input */
{
    return 1; /* terminate now */
}

void handle_conditional(char *str, int len)
{
    int c, d, index;
    int cur_line = yylineno;
    int cur_column = yycolumn - 9;
    int lparen = FALSE;
    int in_quote = FALSE;
    int in_sing_quote = FALSE;
    int miss_spc;
    char result_str[MAX_STRING];

    for (index = 0; index < len; index++)
    {
        result_str[index] = str[index];
    }
    
    result_str[index] = '\0';
   
    c = input();
    d = input();

    if ((!isblank(c) && c != '(') || (isblank(c) && d != '('))
        return;
    else
        unput(d);

    miss_spc = c;
    
    while(TRUE)
    {
        switch(c)
        {
          case EOF:
            return;

          case '(':
            if (!in_quote && !in_sing_quote)
              lparen++;
            break;

          case ')':
            if (!in_quote && !in_sing_quote)
              lparen--;
            break;

          case '{':
            if (!in_quote && !in_sing_quote)
            {
              
              if (!isblank(miss_spc))
              {
                printf("%d:\n\n\t%s\n\n'%s' is not followed by whitespace.\n\n",
                        cur_line, result_str, str);

                printf("%d:\n\n\t%s{\n\n'{' should be on a new line.\n\n",
                        yylineno, result_str);
                return;
              }
              else
              {
                printf("%d:\n\n\t%s{\n\n'{' should be on a new line.\n\n",
                        yylineno, result_str);
                return;
              }
            }
            break;

          case '"':
            in_quote = 1 - in_quote;
            break;
        
          case '\'':
            if (!in_quote)
                in_sing_quote = 1 - in_sing_quote;
            break;

          case '\\':
            if (!in_sing_quote)
              d = input();
              if (d == '\n')
                  unput(d);
            break;

          case '\n':
            if (lparen == 0)
            {
              if (!isblank(miss_spc))
              {
                printf("%d:\n\n\t%s\n\n'%s' is not followed by whitespace.\n\n",
                        cur_line, result_str, str);
                return;
              }
              else
                return;
            }
            else
            {
              if (index < MAX_STRING - 1) 
              {
                  result_str[index++] = c;
                  result_str[index] = '\0';
              }
              int i;
              for (i = 0; i < cur_column; i++)
              {
                c = input();

                if (!isblank(c))
                    break;
              }
            }
            break;

          default:
            break;
        }

        if (index < MAX_STRING - 1)
        {
            result_str[index++] = c;
            result_str[index] = '\0';
        }
        c = input();   
    }
}

