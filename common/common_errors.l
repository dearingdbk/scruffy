%{

int yycolumn = 0;
/* START Include files. */
#include <stdio.h>
/* END Include files. */

/* START Definitions. */
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
yylloc.first_column = yycolumn; yylloc.last_column = yycolumn+yyleng-1; \
yycolumn += yyleng;

#define RESET(x) x = 0
#define FALSE 0
#define TRUE 1
#define MAX_STRING 1024
#include <string.h>
#ifndef COMMON_ERRORS_TAB_H
#define COMMON_ERRORS_TAB_H
#include "common_errors.tab.h"
#endif

char *trim(char *str);
void handle_conditional(char *str, int line);
%}

%option yylineno

%x COMMENT

%%

"/*"                    { BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL);}
<COMMENT><<EOF>>        { printf("%d: Unterminated comment\n",yylineno); return EOF; }
<COMMENT>([^*]|\n)+|.


"//".*                  /* Eat up single line comments. */

^[ \t]*

"while"                 | 
"for"                   |
"if"                    { handle_conditional(yytext, yyleng); }

.*"struct"[^\n=]*"{"     {  printf("%d:\n\n\t%s\n\n'{' should be on a new line.\n\n",
                                  yylineno, trim(yytext));
                        }

\n                      { RESET(yycolumn); }
.                       { /* append_text(yytext, yyleng); */ }

%%
main(int argc, char **argv)
{
    yylex();
}

int yywrap(void) /* called at end of input */
{
    return 1; /* terminate now */
}

/*
void append_text(char *str, int len)
{   
    int i;
    for (i = 0; i < len; i++)
    {
        tmp[strpos++] = str[i];
    }
    tmp[strpos] = '\0';
}

void reset_text()
{
    strpos = 0;
    tmp[0] = '\0';
}
*/

void handle_conditional(char *str, int len)
{
    int c, d, index;
    int cur_line = yylineno;
    int cur_column = yycolumn - 9;
    int lparen = 0;
    int in_quote = 0;
    int in_sing_quote = 0;
    int miss_spc;
    char result_str[MAX_STRING];

    for (index = 0; index < len; index++ )
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
              result_str[index++] = c;
              result_str[index] = '\0';
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

        if (index < MAX_STRING)
        {
            result_str[index++] = c;
            result_str[index] = '\0';
        }
        c = input();   
    }
}



char *trim(char *str)
{
    char *tmp;
    tmp = strdup(str);

    while(isspace(*tmp)) tmp++;

    if(*tmp == '\0')
        return tmp;

    return tmp;
}
