/*
 * File:     functions.c
 * Author:   Bruce Dearing 100036623
 * Date:     30/11/2013
 * Version:  1.0
 * Purpose:  Program to handle functions common to all portions of
 *           C style checker.
 */

#include "functions.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#define MAX_STRING 1024
#define BAD_IDENT_MSG 50
#define MAGIC_NUM_MSG 25
#define MAX_LINE_LEN 79
char linebuf[MAX_STRING];
int strpos = 0;



/*
 * Name: print_bad_ident
 * Purpose: 
 * Arguments: 
 * Output: 
 * Modifies: 
 * Returns: 
 * Assumptions: 
 * 
 * Bugs: 
 * Notes:
 */
void
print_bad_ident(int line, int column, char *str)
{
    char *rtnstr = strdup((const char *)&linebuf);
    int orig_len = strlen(rtnstr);
    rtnstr = trim(rtnstr);
    int new_len = strlen(rtnstr);
    int delta = orig_len - new_len;
    column = column - delta;
    int len = strlen(str) + BAD_IDENT_MSG;
    char *msg = (char *) malloc(sizeof(char *) * len);

    msg = strcat(msg, "Name '");
    msg = strcat(msg, str);
    msg = strcat(msg, "' must match pattern '^[a-z][a-zA-Z0-9_]*$'.");

    printf("%d:\n\n\t%s\n\t%*s%s\n%s\n\n", <br>           line, rtnstr, column, " ", "^", msg);
    free(msg);
}


/*
 * Name:        print_comment_msg
 * Purpose:     
 * Arguments:   
 * Output:      
 * Modifies:    
 * Returns:     
 * Assumptions: 
 *              
 * Bugs:       
 * Notes:       
 */
void
print_comment_msg(int line, char *type, char *name)
{

    printf("%d:\n\n%s %s %s %s %s.\n\n", line, "Missing", name, "label inside",
           type, "comment");
}


/*
 * Name:        trim
 * Purpose:     Trims the whitespace from the beggining of a string.
 * Arguments:   str ~ pointer to an array of chars to trim the whitespace.
 * Output:      none.
 * Modifies:    none.
 * Returns:     return a new string with whitespace trimmed from beginning.
 * Assumptions: The pointer is to a valid string.
 *              The string contains more than whitespace.
 * Bugs:        none found to date.
 * Notes:       
 */
void
print_magic_number(int line, int column, char *str)
{
    char *rtnstr = strdup((const char *)&linebuf);
    int orig_len = strlen(rtnstr);
    rtnstr = trim(rtnstr);
    int new_len = strlen(rtnstr);
    int delta = orig_len - new_len;
    column = column - delta;

    int len = strlen(str) + MAGIC_NUM_MSG;
    char *msg = (char *) malloc(sizeof(char *) * len);

    msg = strcat(msg, "Warning: '");
    msg = strcat(msg, str);
    msg = strcat(msg, "' might be a magic number.");

    printf("%d:\n\n\t%s\n\t%*s%s\n%s\n\n",<br>           line, rtnstr, column, " ", "^", msg);

    free(msg);
}


/*
 * Name:        trim
 * Purpose:     Trims the whitespace from the beggining of a string.
 * Arguments:   str ~ pointer to an array of chars to trim the whitespace.
 * Output:      none.
 * Modifies:    none.
 * Returns:     return a new string with whitespace trimmed from beginning.
 * Assumptions: The pointer is to a valid string.
 *              The string contains more than whitespace.
 * Bugs:        none found to date.
 * Notes:       
 */
char*
trim(char *str)
{
    char *newstr;
    newstr = strdup(str);

    while (isspace(*newstr))
        newstr++;

    return newstr;
}

/*
 * Name:        print_msg
 * Purpose:     Prints to stdout a message prompting the user for corrections
 *              to be made to submitted code.
 * Arguments:   line ~ the line number where the style error was located.
 *              column ~ the column number where the style error was located.
 *              str ~ pointer to an array of chars representing the message
 *              to the user.
 * Output:      The style error message to the user.
 * Modifies:    none.
 * Returns:     none. 
 * Assumptions: The pointer is to a valid string. The string has a valid
 *              message to pass to the user referencing a style error.
 * Bugs:        none found to date.
 * Notes:       
 */


void
print_msg(int line, int column, char *str)
{
    char *rtnstr = strdup((const char*)&linebuf);
    int orig_len = strlen(rtnstr);
    rtnstr = trim(rtnstr);
    int new_len = strlen(rtnstr);
    int delta = orig_len - new_len;
    column = column - delta;

    if (column >= 0)
    {
        printf("%d:\n\n\t%s\n\t%*s%s\n%s\n\n", line, rtnstr, column, " ", "^", str);
    }
    else
    {
        printf("%d:\n\n\t%s\n\n%s\n\n", line, rtnstr, str);
    }

}


/*
 * Name:        append
 * Purpose:     sets the current full line of code to the line buffer
 * Arguments:   str ~ pointer to an array of chars to add to linebuf.
 * Output:      none.
 * Modifies:    none.
 * Returns:     none.
 * Assumptions: The pointer is to a valid string.
 *              The string contains more than whitespace.
 * Bugs:        none found to date.
 * Notes:       
 */

void
append(int line, char *str, int len)
{
    int i;
    if (len > MAX_STRING)
        len = MAX_STRING;
    for (i = 0; i < len; i++)
    {
        linebuf[i] = str[i];
    }
    linebuf[i] = '\0';
    if (len > MAX_LINE_LEN)
    {
        print_msg(line, 0, "Line is longer than 79 characters");
    }
}


/*
 * Name:        trim
 * Purpose:     Trims the whitespace from the beggining of a string.
 * Arguments:   str ~ pointer to an array of chars to trim the whitespace.
 * Output:      none.
 * Modifies:    none.
 * Returns:     return a new string with whitespace trimmed from beginning.
 * Assumptions: The pointer is to a valid string.
 *              The string contains more than whitespace.
 * Bugs:        none found to date.
 * Notes:       
 */
char*
fix_string(char* string)
{
    int i;
    int len = strlen(string);
    char *ret_str = strdup(string);

    for (i = 0; i < len; i++)
    {
        if (ret_str[i] == ';')
            ret_str[i] = '\0';

    }       
    return ret_str;
}


