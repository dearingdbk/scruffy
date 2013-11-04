#include "functions.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>

extern char *tmp;

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
print_bad_ident(int line, int column, char *str)
{
    char *rtnstr = strdup((const char*) &tmp);
    rtnstr = trim(rtnstr);

    int len = strlen(str) + 50;
    char *msg = (char*) malloc(sizeof(char*) * len);

    msg = strcat(msg, "Name '");
    msg = strcat(msg, str);
    msg = strcat(msg, "' must match pattern '^[a-z][a-zA-Z0-9_]*$'.");

    printf("%d,%d:\n\n\t%s\n\n%s\n\n", line, column, rtnstr, msg);

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

    while(isspace(*newstr))
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
    char *rtnstr = strdup((const char*) &tmp);
    rtnstr = trim(rtnstr);

    if ( column != 0 )
    {
        printf("%d,%d:\n\n\t%s\n\n%s\n\n", line, column, rtnstr, str);
    }
    else
    {
        printf("%d:\n\n\t%s\n\n%s\n\n", line, rtnstr, str);
    }

}

