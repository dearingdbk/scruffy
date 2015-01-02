/*
 * File:     functions.c
 * Author:   Bruce Dearing 100036623
 * Date:     30/11/2013
 * Version:  1.1
 * Purpose:  Program to handle functions common to a number of 
 *           components of the C style checker.
 *
 * Mods:     2014/09/01 Jim Diamond removed some redundant code,
 *	     fixed memory leaks, removed compiler warnings and did
 *           some arguably gratuitous reformatting.
 */

#include "functions.h"

#include    <ctype.h>
#include    <stdio.h>
#include    <string.h>
#include    <stdlib.h>
#include    <stdarg.h>

#define     MAX_STRING	    1024
#define	    MAX_LINE_LEN      79

static char linebuf[MAX_STRING];


/*
 * Name:         print_bad_ident
 * Purpose:      Prints to stdout the error message associated with
 *               a file containing a naming violation on a type name
 *               or variable.
 * Arguments:    line: the line number where the violation occurred.
 *               column: the column position where the violation occurred.
 *               str: the string representing the token which violated.
 * Output:       Prints to stdout the appropriate error message.
 * Modifies:     None.
 * Returns:      None.
 * Assumptions:  str is a valid char * pointer and the line contains 
 *               characters other than white space.
 * 
 * Bugs:         None known.
 * Notes:
 */

void
print_bad_ident(int line, int column, const char * str)
{
    const char * fnw = first_non_white(linebuf);

    column += linebuf - fnw;

    printf("%d:\n\n\t%s\n\t%*s%s\n", line, fnw, column, " ", "^");
    printf("Name '%s' must match pattern '^[a-z][a-zA-Z0-9_]*$'.\n\n", str);
}



/*
 * Name:        print_comment_msg
 * Purpose:     Prints to stdout the error message associated with
 *              a file containing a poorly formatted or missing comment.
 * Arguments:   line: the line number where the violation occurred.
 *              type: the type of label that is missing, dependent on
 *              comment type.
 *              name: the string containing the comment type:
 *		"header" or "function".
 * Output:      Prints to stdout the appropriate error message.
 * Modifies:    None.
 * Returns:     None.
 * Assumptions: str is a valid char * pointer and the line contains 
 *              characters other than white space.
 * Bugs:        none known to date.
 * Notes:
 */

void
print_comment_msg(int line, const char * type, const char * name)
{

    printf("%d:\n\nMissing or unrecognized %s label in %s comment.\n\n",
	   line, name, type);
}



/*
 * Name:         print_magic_number
 * Purpose:      Prints to stdout the error message associated with
 *               a file containing a magic number.
 * Arguments:    line: the line number where the violation occurred.
 *               column: the column position where the violation occurred.
 *               str: the string representing the token which violated.
 * Output:       Prints to stdout the appropriate error message.
 * Modifies:     None.
 * Returns:      None.
 * Assumptions:  str is a valid char * pointer and the line contains 
 *               characters other than white space.
 * Bugs:         none to date.
 * Notes:
 */

void
print_magic_number(int line, int column, const char * str)
{
    const char * fnw = first_non_white(linebuf);

    column += linebuf - fnw;

    printf("%d:\n\n\t%s\n\t%*s%s\n", line, fnw, column, " ", "^");
    printf("Warning: '%s' might be a magic number\n\n", str);
}



/*
 * Name:        first_non_white
 * Purpose:     Get a pointer to the first non-space char of the arg.
 * Arguments:   str: a pointer to a string.
 * Output:      None.
 * Modifies:    None.
 * Returns:     A pointer to the first non-white char
 *		(or the terminating NULL, if no non-white char).
 * Assumptions: The pointer is to a valid string.
 *              The string contains more than whitespace.
 * Bugs:        None found to date.
 * Notes:	None.
 */

const char *
first_non_white(const char * str)
{
    while (isspace(*str))
	str++;
    
    return str;
}



/*
 * Name:        print_msg
 * Purpose:     Prints to stdout a message prompting the user for corrections
 *              to be made to submitted code.
 * Arguments:   line: the line number where the style error was located.
 *              column: the column number where the style error was located.
 *              str: pointer to an array of chars representing the message
 *              to the user.
 * Output:      The style error message to the user.
 * Modifies:    None.
 * Returns:     None. 
 * Assumptions: The pointer is to a valid string. The string has a valid
 *              message to pass to the user referencing a style error.
 * Bugs:        None found to date.
 * Notes:       
 */

void
print_msg(int line, int column, char * str)
{
    const char * fnw = first_non_white(linebuf);

    column += linebuf - fnw;

    if (column >= 0)
        printf("%d:\n\n\t%s\n\t%*s%s\n%s\n\n", line, fnw, column,
               " ", "^", str);
    else
        printf("%d:\n\n\t%s\n\n%s\n\n", line, fnw, str);

}


/*
 * Name:        append
 * Purpose:     Copies the current full line of code to the line buffer
 * Arguments:   str: pointer to an array of chars to add to linebuf.
 * Output:      None.
 * Modifies:    None.
 * Returns:     None.
 * Assumptions: The pointer is to a valid string.
 *              The string contains more than whitespace.
 * Bugs:        None found to date.
 * Notes:       
 */

void
append(int line, char * str, int len)
{
    //fprintf(stderr, "************************\n%d:%s\n", len, str);

    if (len > MAX_STRING)
        len = MAX_STRING;
    strncpy(linebuf, str, len - 1);
    linebuf[len - 1] = '\0';

    /* reduce len by one because we have added in '\n' character. */
    if ((len - 1) > MAX_LINE_LEN)
        print_msg(line, 0, "Line is longer than 79 characters");
}


/*
 * Name:        fix_string
 * Purpose:     Strips a trailing semi-colon from a string in the case
 *              of a typedef.
 * Arguments:   string: pointer to an array of chars from which to trim the
 *              semi-colon.
 * Output:      None.
 * Modifies:    None.
 * Returns:     Return a new string stripped of the semicolon.
 * Assumptions: The pointer is to a valid string.
 *              The string contains more than whitespace.
 * Bugs:        None found to date.
 * Notes:       
 */

char *
fix_string(char * string)
{
    int i;
    int len = strlen(string);
    char * ret_str = strdup(string);

    for (i = 0; i < len; i++)
    {
        if (ret_str[i] == ';')
        {
            ret_str[i] = '\0';
            break;
        }
    }       

    return ret_str;
}
