#include "functions.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#define MAX_STRING 1024
#define BAD_IDENT_MSG 50
#define MAGIC_NUM_MSG 25
//extern char *tmp;
char tmp[MAX_STRING];
int strpos = 0;

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
    char *rtnstr = strdup((const char*)&tmp);
    rtnstr = trim(rtnstr);

    int len = strlen(str) + BAD_IDENT_MSG;
    char *msg = (char*) malloc(sizeof(char*) * len);

    msg = strcat(msg, "Name '");
    msg = strcat(msg, str);
    msg = strcat(msg, "' must match pattern '^[a-z][a-zA-Z0-9_]*$'.");

    printf("%d,%d:\n\n\t%s\n\n%s\n\n", line, column, rtnstr, msg);

    free(msg);
}

void
print_magic_number(int line, int column, char *str)
{
    char *rtnstr = strdup((const char*)&tmp);
    rtnstr = trim(rtnstr);

    int len = strlen(str) + MAGIC_NUM_MSG;
    char *msg = (char*) malloc(sizeof(char*) * len);

    msg = strcat(msg, "'");
    msg = strcat(msg, str);
    msg = strcat(msg, "' is a magic number.");

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
    char *rtnstr = strdup((const char*)&tmp);
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

void
append(char *str, int len)
{
    int i;
    if (strpos + len >= 1024)
        return;
    for (i = 0; i < len; i++)
    {
        tmp[strpos++] = str[i];

    }
    tmp[strpos] = '\0';
}


void
reset_text()
{
    tmp[0] = '\0';
    strpos = 0;
}

char*
fix_string(char* string)
{
    int i;
    int len = strlen(string);
    char* ret_str = strdup(string);

    for (i = 0; i < len; i++)
    {
        if (ret_str[i] == ';')
            ret_str[i] = '\0';

    }       
    return ret_str;
} 
