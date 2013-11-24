/*
 * File:     common_errors.l
 * Author:   Bruce Dearing 100036623
 * Date:     2013/20/11
 * Version:  1.0
 * Purpose:  Flex tokenizer and functions to handle common white space errors. 
 */

%{


/* START Include files. */
#include <stdio.h>
#include <string.h>
#include "../functions/functions.h"
/* END Include files. */

/* START Definitions. */
#define YY_USER_ACTION yycolumn += yyleng;
#define RESET(x) x = 0
#define FALSE 0
#define TRUE 1
#define MAX_STRING 1024
#define TAB_WIDTH 9
/* END Definitions */

/* START Declarations */
void handle_conditional(char *str, int line);
int yycolumn = 0;
/* END Declarations */

%}

/*
 * Parser options
 *  
 * yylineno: The %yylineno option tells flex to define an integer
 *           variable called yylineno and to maintain the current line
 *           number in it. Every time the scanner reads a '\n', it 
 *           increments yylineno, and if the scanner backs up over
 *           a '\n', it decrements it.
 */

%option yylineno

/* START Exclusive start state definitions. */
%x COMMENT
%x DEFINE
%x STRING
%x INCLUDE
/* END Exclusive start state definitions. */

%%

^"#"[ \t]*"include".*        { BEGIN(INCLUDE); }
<INCLUDE>.
<INCLUDE>\n                  { RESET(yycolumn);  BEGIN(INITIAL); }

^"#"[ \t]*"define"           { BEGIN(DEFINE);}
<DEFINE>.|\n
<DEFINE>[^\\]\n              { RESET(yycolumn); BEGIN(INITIAL); }


"/*"                         { BEGIN(COMMENT); }
<COMMENT>"*/"                { BEGIN(INITIAL);}
<COMMENT><<EOF>>             { printf("%d: Unterminated comment\n",yylineno); 
                               return EOF;
                             }
<COMMENT>([^*]|\n)+|.

"//".*                        /* Eat up single line comments. */

^"#"[ \t]*"undef".*          |
^"#"[ \t]*"if".*             |
^"#"[ \t]*"elif".*           |
^"#"[ \t]*"else".*           |
^"#"[ \t]*"endif".*          |
^"#"[ \t]*"line".*           |
^"#"[ \t]*"error".*          |
^"#"[ \t]*"pragma".*         |
^"#"                         ; /* Eat up preprocessor directives. */

^[ \t]*                      /* Eat up white space at the start of a line. */

"while"                      | 
"do"                         |
"for"                        |
"if"                         { handle_conditional(yytext, yyleng); }

.*"struct"[^\n=]*"{"         { printf("%d:\n\n\t%s\n\n'{' %s\n\n",
                                  yylineno, trim(yytext), 
                                  "should be on a new line.");
                             }

\n                           { RESET(yycolumn); }

.                            /* Eat up bad characters. */

%%


/*      
 * Name:        main 
 * Purpose:     calls yylex() to tokenize input.
 * Arguments:   
 * Output:      none
 * Modifies:    none
 * Returns:     
 * Assumptions: 
 * Bugs:        
 * Notes:
 */ 
void 
main(int argc, char **argv)
{
    yylex();
}


/*      
 * Name:        yywrap 
 * Purpose:     called at the end of output to signal end.
 * Arguments:   none
 * Output:      none
 * Modifies:    none
 * Returns:     1
 * Assumptions: 
 * Bugs:        
 * Notes:
 */ 
int 
yywrap(void)
{
    return 1; /* terminate now */
}


/*      
 * Name:        handle_conditional 
 * Purpose:     checks conditional statements for whitespace and bracket
 *              location on the first line.
 * Arguments:   str ~ The conditional start: if, while, for, and do.
 *              len ~ The length of the string str.
 * Output:      if the conditional is not followed by whitespace:
 *              Prints warning message.
 *              if the lcurly bracket is not on a new line:
 *              Prints warning message.
 * Modifies:    none
 * Returns:     void.
 * Assumptions: The conditional statement including the conditionals up to 
 *              newline is less than MAX_STRING.
 * Bugs:        
 * Notes:
 */ 
void 
handle_conditional(char *str, int len)
{
    int c, d, index;
    int cur_line = yylineno;
    int cur_column = yycolumn - TAB_WIDTH;
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

    if ((!isblank(c) && c != '(' && c != '{')
        || (isblank(c) && d != '(' && d != '{'))
        return;

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
                    printf("%d:\n\n\t%s\n\n'%s' %s\n\n",
                           cur_line, result_str, str, 
                           "is not followed by whitespace.");

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
                    printf("%d:\n\n\t%s\n\n'%s' %s\n\n",                        
                           cur_line, result_str, str,                           
                           "is not followed by whitespace.");  
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
