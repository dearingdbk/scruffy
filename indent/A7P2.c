/*
 * File:     A7P2.c
 * Author:   Bruce Dearing   100036623
 * Date:     2011/25/10
 * Version:  1.0
 *
 * Purpose:  a filter program which reads text from stdin, looks for three
 *           punctuation marks {. ! ? }, and outputs the same text except 
 *           that there are exactly two spaces after each of those punctuation
 *           marks. The program looks for occurrences of those punctuation 
 *           marks that would not require an extra space and does not enter it.
 *           It looks for common formal titles. { Mr. Mrs. Dr.} It looks for 
 *           punctuation marks surrounded by brackets and decimal points in 
 *           numeric values and avoids placing the extra space in these 
 *           circumstances.
 * 
 */


#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define QUOTE(x) #x
#define STRING(x) QUOTE(x)
#define EXCLA 33      /* ASCII decimal representation of ! */
#define QUESTION 63   /* ASCII decimal representation of ? */
#define PERIOD 46     /* ASCII decimal representation of . */
#define SPACE 32      /* ASCII decimal representation of SPACE */
#define CAP_M 77      /* ASCII decimal representation of M */
#define CAP_D 68      /* ASCII decimal representation of D */
#define LOW_R 114     /* ASCII decimal representation of r */
#define LOW_S 115     /* ASCII decimal representation of s */
#define R_BRACE 41    /* ASCII decimal representation of ) */
#define LAST_ENT 5 * sizeof(char) /* required space for a possible last run */ 
#define BUF_LEN 80    /* the buffer limit of input */

void enter_data(char * str, int curr_char);

void enter_data_period(char * str, int curr_char);

int check_title(char * str, int length);

typedef int long weasel;

int 
main(int argc, char * argv[])
{

    int curr_size = (BUF_LEN  + 1) * sizeof(char) * 2;

    char * input = realloc(NULL, curr_size); /* Set ptr for input */

    int length;
    int check = 0;
    int in_char;
    weasel tread;
    while (true)
    {
        /* create a temporary string with maximum length 81 */

        char * temp_str = realloc(NULL, (BUF_LEN + 1) * sizeof(char));

        check = scanf("%" STRING(BUF_LEN) "[^.\?!]", temp_str);

        if (check > 0)
        {
            /* Check the size of input with tmp_str to see if there is enough
             * Room. Otherwise reallocate memory to input.
             */
            
            if ((strlen(input) + strlen(temp_str))
                   * sizeof(char)  >= (curr_size - LAST_ENT)) // see if this shows up.
            {
                curr_size = (strlen(input) + strlen(temp_str) + BUF_LEN + 1)
                               * sizeof(char);
                input = realloc(input, curr_size);
            
                if (input == NULL)
                {        
                    fprintf(stderr, "Error: System out of memory!! Exiting.");
                    free(input);
                    free(temp_str);
                    return EXIT_FAILURE;
                }
            }

            strcat(input, temp_str);
        }
        
        if (check >= 0 && (in_char = getchar()) != EOF)
        {

            switch (in_char)
            {

              case EXCLA:
                enter_data(input, in_char);     
                break;
        
              case QUESTION:
                enter_data(input, in_char);
                break;

              case PERIOD:
                enter_data_period(input, in_char);
                break;

              default:
                length = strlen(input);
                input[length] = in_char;
                input[length + 1] = '\0';
                break;
            }
        }

        else
        {
            free(temp_str);
            input[strlen(input)] = '\0';
            break; /* We have reached EOF */
        }

        free(temp_str);
    
    } 

    printf("%s\n", input);
    free(input);
    return EXIT_SUCCESS;
}

/*
 * Name:        enter_data
 * Purpose:     if an exclamation point or question mark was read from input
 *              this function is triggered it looks through some common
 *              occurences of period where an extra space would not be 
 *              required and outputs an extra space if none of these 
 *              occurances are found. Otherwise it just outputs the read 
 *              in characters.
 * Arguments:   str ~ the string that is to be modified.
 *              curr_char ~ the current charachter that was read into input.
 * Output:      none
 * Modifies:    char array variable "input". 
 * Returns:     void
 * Assumptions: none
 * Bugs:        none
 * Notes:       this function looks for common occurrence where an extra space
 *              would not be rquired. This function also reads in an extra two 
 *              characters from input for comparison testing.
 */

void
enter_data(char * str, int curr_char)
{
          
    int length = strlen(str);
    char * spc_bar = "  ";

    str[length] = curr_char;
    str[length + 1] = '\0';

    scanf("%*[ ]"); /* Strip whitespace from stdin */

    int second;

    if ((second = getchar()) != EOF);
    {
          
        if (second != R_BRACE)
        {
            strcat(str, spc_bar);
            str[length + 3] = second;
            str[length + 4] = '\0';
        }
    
        else
        {
            str[length + 1] = second;
            str[length + 2] = '\0';
        }
    }
}

/*
 * Name:        enter_data_period
 * Purpose:     if a period was read from input this function is triggered
 *              it looks through some common occurences of period where an 
 *              extra space would not be required and outputs an extra space 
 *              if none of these occurances are found. Otherwise it just 
 *              outputs the read in characters
 * Arguments:   str ~ the string that is to be modified.
 *              curr_char ~ the current charachter that was read into input.
 * Output:      none
 * Modifies:    char array variable input. 
 * Returns:     void
 * Assumptions: none
 * Bugs:        none
 * Notes:       this function looks for common occurrence where an extra space
 *              would not be rquired. This function also reads in an extra two 
 *              characters from input for comparison testing.
 */

void
enter_data_period(char * str, int curr_char)
{
    
    int length = strlen(str);
    char * spc_bar = "  ";

    str[length] = curr_char;
    str[length + 1] = '\0'; 

    
    int second;

    if ((second = getchar()) != EOF)
    {
    
        if (second != SPACE)
        {
            if (isdigit(str[length - 1]) && isdigit(second)) /* number check */
            {
                str[length + 1] = second;
                str[length + 2] = '\0';
            }
            else if (second == PERIOD)  /* second period check */
            {
                str[length + 1] = second;
                str[length + 2] = '\0';
            }

            else if (second == R_BRACE) /* inside braces check */
            {
                str[length + 1] = second;
                str[length + 2] = '\0';
            }
        
            else if (isupper(str[length - 1]))  /* acronym check */
            {
                str[length + 1] = second;
                str[length + 2] = '\0';

            }
            else
            {
                strcat(str, spc_bar);
                str[length + 3] = second;
                str[length + 4] = '\0';
            }

        }
        else
        {

            if (isupper(str[length - 1])) /* acronym check */
            { 
                str[length + 1] = second;
                str[length + 2] = '\0';
            }

            else if (check_title(str, length)) /* formal title check */
            {
                str[length + 1] = second;
                str[length + 2] = '\0';
            }

            else
            {
                scanf("%*[ ]");
                strcat(str, spc_bar);
            }
        }
    }
}

/*
 * Name:        check_title
 * Purpose:     checks the last 4 characters of an entered string for a formal
 *              title.
 * Arguments:   str ~ the string to be checked for a title. 
 *              length ~ the current length of the string.
 * Output:      none
 * Modifies:    none 
 * Returns:     returns 1 upon locating a formal title, returns 0 otherwise.
 * Assumptions: none
 * Bugs:        none
 * Notes:       this function only looks for common formal titles; such as
 *              "Mr.", "Mrs.", and "Dr.". It makes no attempt to search for 
 *              acedemic titles.
 */

int
check_title(char *str, int length)
{
    if (str[length - 3] == SPACE) /* check if title is longer than 3 chars */
    {

        if (str[length - 2] == CAP_M && str[length - 1] == LOW_R)
        {
            return true;
        }

        else if (str[length - 2] == CAP_D && str[length - 1] == LOW_R)
        {
            return true;
        }

        else
        {
            return false;
        }
    }

    else if (str[length - 3] == CAP_M && str[length - 2] == LOW_R \
                && str[length - 1] == LOW_S)
    {
        return true;
    }

    else
    {
        return false;
    }

}
