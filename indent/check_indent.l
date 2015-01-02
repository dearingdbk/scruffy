/*
 * File:     check_indent.l
 * Author:   Bruce Dearing 100036623
 * Date:     2013/20/11
 * Version:  1.1
 * Purpose:  Flex tokenizer designed to read diff output from the 
 *           the supplied file after it has been indented with a vim 
 *           script, and calculate the original column and the required
 *           column space.
 *
 * Mods:     2014/09/01 Jim Diamond.  Remove some compiler warnings,
 *           do a bit of reformatting.  Fix incorrect comments and a
 *	     buglet related to array overflow in handle_text().
 */

%{
    
/* START Include files. */
#include <stdio.h>
#include <string.h>
/* END Include files. */

/* START Definitions. */
#define YY_USER_ACTION yycolumn += yyleng;
#define RESET(x) x = 0
#define MAX_LENGTH 80
#define DECIMAL 10
/* END Definitions */

/* START Program variables */
typedef struct 
{
    int orig_start;
    int orig_end;
    int new_start;
    int new_end;
    int orig_spaces;
    int new_spaces;
    char *text;
} diff_output;

diff_output current; 
int col_num = 0;
int indent = 0;
int yycolumn = 0;
/* END Program variables */

/* START Function Definitions */
void set_multi(diff_output *current, char *text);
void set_single(diff_output *current, char *text);
void output_results(diff_output *current);
void handle_text(diff_output *current);
/* END Function Definitions */

%}

%option yylineno


%x ORIG_SPACE
%x NEW_SPACE
%x GET_TEXT
%x READ_TO_END

%%

<ORIG_SPACE>\n          {RESET(yycolumn);}
<ORIG_SPACE>^" "*       {current.orig_spaces = (yycolumn);\
                         handle_text(&current);\
                         BEGIN(READ_TO_END);}
<ORIG_SPACE>^.          {RESET(current.orig_spaces);\
                        handle_text(&current);\
                        BEGIN(READ_TO_END);}

<READ_TO_END>"---"      {BEGIN(NEW_SPACE);}
<READ_TO_END>"$$$"      {output_results(&current); BEGIN INITIAL;}
<READ_TO_END>.*         
<READ_TO_END>\n         {RESET(yycolumn);}

<NEW_SPACE>\n           {RESET(yycolumn); }
<NEW_SPACE>^" "*        {current.new_spaces = (yycolumn); BEGIN(READ_TO_END); }
<NEW_SPACE>^.           {RESET(current.new_spaces); BEGIN(READ_TO_END); }

<<EOF>>                              {return EOF;}
[0-9]+","[0-9]+[a-z][0-9]+","[0-9]+  {set_multi(&current, yytext); BEGIN(ORIG_SPACE);}
[0-9]+[a-z][0-9]+                    {set_single(&current, yytext); BEGIN(ORIG_SPACE);}

\n                      {RESET(yycolumn);}
.

%%


/*      
 * Name:        main 
 * Purpose:     calls yylex() to tokenize input.
 * Arguments:   
 * Output:      None
 * Modifies:    None
 * Returns:     
 * Assumptions: 
 * Bugs:        
 * Notes:
 */ 

int
main(int argc, char * argv[])
{
    return yylex();
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
yywrap(void) /* called at end of input */
{
    return 1; /* terminate now */
}



/*  
 * Name:        set_multi
 * Purpose:     Takes multi-line diff output and places the line
 *              numbers into their appropriate place in the struct
 *              diff_output. 
 * Arguments:   current: the current diff_output struct.
 *              text: the text to strip out line numbers from.
 * Output:      None
 * Modifies:    current.
 * Returns:     Nothing.
 * Assumptions: 
 * Bugs:        None
 * Notes:       multi line diff output - 18,22c18,22
 */

void
set_multi(diff_output * current, char * text)
{
    char * tmp = strdup(text);

    current->orig_start = strtol(tmp, &tmp, DECIMAL);
    tmp++;
    current->orig_end = strtol(tmp, &tmp, DECIMAL);
    tmp++;
    current->new_start = strtol(tmp, &tmp, DECIMAL);
    tmp++;
    current->new_end = strtol(tmp, &tmp, DECIMAL);
}



/*  
 * Name:        set_single
 * Purpose:     takes single line diff output and places the line
 *              numbers into their appropriate place in the struct
 *              diff_output. 
 * Arguments:   current ~ the current diff_output struct.
 *              text ~ the text to strip out line numbers from.
 * Output:      none
 * Modifies:    current.
 * Returns:     void.
 * Assumptions: 
 * Bugs:        none
 * Notes:       single line diff output - 16c16
 */

void
set_single(diff_output * current, char * text)
{
    char * tmp = strdup(text);

    current->orig_start = strtol(tmp, &tmp, DECIMAL);
    current->orig_end = current->orig_start;
    tmp++;
    current->new_start = strtol(tmp, &tmp, DECIMAL);
    current->new_end = current->new_start;

}



/*  
 * Name:        output_results
 * Purpose:     Outputs to stdout the appropriate message representing 
 *              the required change in indentation.
 * Arguments:   str: The string to search for in the symbol_table.
 * Output:      An error message for the user.
 * Modifies:    None.
 * Returns:     Nothing.
 * Assumptions: 
 * Bugs:        None.
 * Notes:       
 */

void
output_results(diff_output * current)
{
    if (current->orig_start == current->orig_end)
    {
        printf("%d:\n\t%s\n\nCode at indentation level [%d] "
                "not at correct indentation [%d].\n\n", 
                current->orig_start,
                current->text,
                current->orig_spaces, 
                current->new_spaces);
    }
    else
    {
        printf("%d - %d:\n\t%s\n\t\tcode continues...\n\n"
               "Code at indentation level [%d] "
               "not at correct indentation [%d].\n\n",
                current->orig_start,
                current->orig_end,
                current->text,
                current->orig_spaces,
                current->new_spaces);
    }

    current->text = "";
}



/*  
 * Name:        handle_text
 * Purpose:     place the code from the first line of the diff
 *              into the diff_output struct.
 * Arguments:   current: the diff_output struct.
 * Output:      None.
 * Modifies:    None.
 * Returns:     Nothing.
 * Assumptions: 
 * Bugs:        None
 * Notes:
 */

void
handle_text(diff_output * current)
{
    int index = 0;
    int c;
    char tmp[MAX_LENGTH];

    while (1)
    {
        c = input();
        if (c == '\n' || c == EOF)
            break;
        else
        {
            tmp[index++] = c;
            if (index == MAX_LENGTH - 1)
                break;
        }
    }

    tmp[index] = '\0';
    current->text = strdup(tmp);
}
