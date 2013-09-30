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

#include <string.h>
#include "check_indent.tab.h"
typedef struct 
{
    int orig_start;
    int orig_end;
    int new_start;
    int new_end;
    int orig_spaces;
    int new_spaces;
    char *text;
}diff_output;

diff_output current; 
int col_num = 0;
int indent = 0;

void set_multi(diff_output *current, char *text);
void set_single(diff_output *current, char *text);
void output_results(diff_output *current);
void handle_text(diff_output *current);
%}

%option yylineno


%x ORIG_SPACE
%x NEW_SPACE
%x GET_TEXT
%x READ_TO_END
%x SECOND_LINE
%x PROCESS_LINE
%x COMMENT

%%

<ORIG_SPACE>\n          {RESET(yycolumn);}
<ORIG_SPACE>^" "*       {current.orig_spaces = (yycolumn);\
                         handle_text(&current);\
                         BEGIN(READ_TO_END);}

<READ_TO_END>"---"      {BEGIN(NEW_SPACE);}
<READ_TO_END>"$$$"      {output_results(&current); BEGIN INITIAL;}
<READ_TO_END>.*         
<READ_TO_END>\n         {RESET(yycolumn);}

<NEW_SPACE>\n           {RESET(yycolumn); }
<NEW_SPACE>^" "*        {current.new_spaces = (yycolumn); BEGIN(READ_TO_END); }

<<EOF>>                              {return EOF;}
[0-9]+","[0-9]+[a-z][0-9]+","[0-9]+  {set_multi(&current, yytext); BEGIN(ORIG_SPACE);}
[0-9]+[a-z][0-9]+                    {set_single(&current, yytext); BEGIN(ORIG_SPACE);}

\n                      {RESET(yycolumn);}
.
%%
main(int argc, char **argv)
{
    yylex();
}

int yywrap(void) /* called at end of input */
{
    return 1; /* terminate now */
}


void set_multi(diff_output *current, char *text)
{
    char *tmp = strdup(text);
    current->orig_start = strtol(tmp, &tmp, 10);
    tmp++;
    current->orig_end = strtol(tmp, &tmp, 10);
    tmp++;
    current->new_start = strtol(tmp, &tmp, 10);
    tmp++;
    current->new_end = strtol(tmp, &tmp, 10);

}

void set_single(diff_output *current, char *text)
{
    char *tmp = strdup(text);
    current->orig_start = strtol(tmp, &tmp, 10);
    current->orig_end = current->orig_start;
    tmp++;
    current->new_start = strtol(tmp, &tmp, 10);
    current->new_end = current->new_start;

}


void output_results(diff_output *current)
{
    if (current->orig_start == current->orig_end)
    {
        printf("%d:\n\t%s\n\nCode at indentation level %d "
                "not at correct indentation, %d.\n\n", 
                current->orig_start,
                current->text,
                current->orig_spaces, 
                current->new_spaces);
    }
    else
    {
        printf("%d - %d:\n\t%s\n\t\tcode continues...\n\nCode at indentation level %d "
                "not at correct indentation, %d.\n\n",
                current->orig_start,
                current->orig_end,
                current->text,
                current->orig_spaces,
                current->new_spaces,
                current->orig_start,
                current->orig_end);
    }

    current->text = "";
}

void handle_text(diff_output *current)
{
    int index = 0;
    int c;
    char tmp[200];
    while (1)
    {
        c = input();
        if (c == '\n')
        {
            break;
        }
        else
        {
            tmp[index++] = c;
        }
    }
    tmp[index] = '\0';
    current->text = strdup(tmp);
}
