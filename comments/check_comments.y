
/*
 * File:     check_comments.y
 * Author:   BD
 * Date:     2013/11/27
 * Version:  1.1
 *
 * Purpose:  ANSI C Yacc grammar, to parse tokens received from the
 *           flex scanner check_comments.l
 *           Grammar has been re-written to identify common style errors
 *           present in C code comments according to style guide.
 *
 * Mods:     2014/09/01 Along with mods in lex file, broke "no ID"
 *	     case out from "no name" case.
 *           A bit of gratuitous reformatting.
 *
 * Notes:    The original code from Bruce crashed if there were no
 *	     valid header lines in the first comment.  JD modified
 *           the code to allow parsing to continue in this case.
 *	     Similarly, the original code gave a bogus complaint of
 *	     invalid header if there was no other /* comment in the
 *	     file.  I introduced a new rule (p_b -> p_s) which hopefully
 *	     does not introduce bugs.  Alternatively, the code in yyerror()
 *	     could check and see if any of the watched-for header lines
 *	     have been set and only complain if none have.
 *
 * Mods:     2014/09/01 Jim Diamond.  Remove some compiler warnings,
 *           do a bit of reformatting.
 */

%locations

%{
    
/* START Include files. */
#ifndef CHECK_COMMENTS_TAB_H
    #define CHECK_COMMENTS_TAB_H
    #include "check_comments.tab.h"
#endif
#include <stdio.h>
#include <string.h>

#include "../functions/functions.h"

/* END Include files. */

/* START Definitions. */
#define YYERROR_VERBOSE
/* END Definitions. */

/* Uncomment this out for debugging purposes: */
// #define DEBUG

#ifdef DEBUG
#define D_PRNT(format, ...) fprintf(stderr, format, ## __VA_ARGS__)
#else
#define D_PRNT(format, ...)
#endif


/* START Program variables */
extern char * yytext;
extern int comment_start;
unsigned int header[LAST_VAL] = {0};
unsigned int function[LAST_VAL] = {0};
/* END Program variables */

/* START Function Definitions */
void check_header();
void check_function();
void yyerror(const char * s);
/* END Function Definitions */


%}
%token  IDENTIFIER FILE_LBL AUTHOR START_COMMENT END_COMMENT VERSION
%token  NAME ARGUMENTS OUTPUT MODIFIES RETURNS ASSUMPTIONS BUGS NOTES 
%token  DATE PURPOSE AUTHOR_AND_ID AUTHOR_WITHOUT_ID LAST_VAL
%start program_body
%%

program_body
    : program_start program_comments
			{ D_PRNT("**** p_b -> p_s p_c\n"); }
    | program_start
			{ D_PRNT("**** p_b -> p_s\n"); }
    ;

program_start
    : START_COMMENT header_comment END_COMMENT
			{ D_PRNT("****p_s -> S_C h_c E_C\n");
			  check_header(); }
    ;

header_comment
    : header_list
			{ D_PRNT("**** h_c -> h_l\n"); }
    |
    			{ D_PRNT("**** h_c -> <nil>\n"); }
    ;

header_list
    : header_label_name
    | header_list header_label_name
    ;

header_label_name
    : FILE_LBL          { header[FILE_LBL] = 1; }
    | AUTHOR_AND_ID     { header[AUTHOR] = 1; }
    | AUTHOR_WITHOUT_ID { header[AUTHOR] = 2; }
    | VERSION           { header[VERSION] = 1; }
    | DATE              { header[DATE] = 1; }
    | PURPOSE           { header[PURPOSE] = 1; }
    ;

program_comments
    : comment_start 
			{ D_PRNT("**** p_c -> c_s\n"); }
    | program_comments comment_start
			{ D_PRNT("**** p_c -> p_c c_s\n"); }
    ;

comment_start
    : START_COMMENT comment_body END_COMMENT
			{ D_PRNT("**** c_s -> S_C c_b E_C\n"); }

comment_body
    : function_comment
			{ D_PRNT("**** c_b -> f_c\n");
			  check_function(); } 
    | /* regular comments */ 
    ;

function_comment
    : function_list
    ;

function_list
    : function_label_name
    | function_list function_label_name
    ;

function_label_name
    : NAME        { function[NAME] = 1; }
    | PURPOSE     { function[PURPOSE] = 1; }
    | ARGUMENTS   { function[ARGUMENTS] = 1; }
    | OUTPUT      { function[OUTPUT] = 1; }
    | MODIFIES    { function[MODIFIES] = 1; }
    | RETURNS     { function[RETURNS] = 1; }
    | ASSUMPTIONS { function[ASSUMPTIONS] = 1; }
    | BUGS        { function[BUGS] = 1; }
    | NOTES       { function[NOTES] = 1; }
    ;

%%



/*      
 * Name:        main 
 * Purpose:     Calls yyparse() to parse input.
 * Arguments:   
 * Output:      None.
 * Modifies:    None.
 * Returns:     None.
 * Assumptions: 
 * Bugs:        
 * Notes:
 */

int
main(int argc, char * argv[])
{
    return yyparse();
} 



/*      
 * Name:        yyerror 
 * Purpose:     Function called to report errors when check_comments is 
 *              unable to parse received tokens.
 * Arguments:   str: the string containing the received error message.
 * Output:      Prints to stdout.
 * Modifies:    None.
 * Returns:     1
 * Assumptions: 
 * Bugs:        
 * Notes:
 */ 

void
yyerror(const char * str)
{
    fprintf(stderr, "%d:\n\n%s\n\n", yylloc.first_line,
	    "Program appears to be missing a valid header comment.");
}



/*      
 * Name:        check_header
 * Purpose:     Verifies that the header file is formatted correctly.
 * Arguments:   None.
 * Output:      Call a separate function to produce error messages
 *              if header labels are missing or malformed.
 * Modifies:    None.
 * Returns:     None.
 * Assumptions: 
 * Bugs:        
 * Notes:
 */ 

void
check_header()
{
    if (header[FILE_LBL] == 0)
	print_comment_msg(comment_start, "\"header\"", "\"File:\"");
    if (header[AUTHOR] == 0)
	print_comment_msg(comment_start, "\"header\"", "\"Author:\"");
    else if (header[AUTHOR] == 2)
	print_comment_msg(comment_start, "\"header\"",
			  "ID number in \"Author:\"");
    if (header[DATE] == 0)
	print_comment_msg(comment_start, "\"header\"", "\"Date:\"");
    if (header[VERSION] == 0)
	print_comment_msg(comment_start, "\"header\"", "\"Version:\"");
    if (header[PURPOSE] == 0)
	print_comment_msg(comment_start, "\"header\"", "\"Purpose:\"");
}



/*      
 * Name:        check_function
 * Purpose:     Verifies that any function file is formatted correctly.
 * Arguments:   None.
 * Output:      Makes a call to print_comment_msg to produce error 
 *              messages if header labels are missing or malformed.
 * Modifies:    None.
 * Returns:     None.
 * Assumptions: function[] is large enough that token flags will not
 *              cause an array index out of range.
 * Bugs:        
 * Notes:
 */ 

void 
check_function()
{
    static unsigned int mask[] = {256, 128, 64, 32, 16, 8, 4, 2, 1};
    int i = 1;
    int k;

    /* 
     * checks which flags in the array have been triggered.\
     * by shifting i by one and then adding in the value of
     * function[<flag>] producing a string of 1's and 0's
     *   101011 
     *
     */ 
    
    i = (i << 1) | function[NAME];
    i = (i << 1) | function[PURPOSE];
    i = (i << 1) | function[ARGUMENTS];
    i = (i << 1) | function[OUTPUT];
    i = (i << 1) | function[MODIFIES];
    i = (i << 1) | function[RETURNS];
    i = (i << 1) | function[ASSUMPTIONS];
    i = (i << 1) | function[BUGS];
    i = (i << 1) | function[NOTES];

    memset(function, 0, sizeof(function));

    for (k = 0; k < 9; k++)
    {
        if ((i & mask[k]) == 0)
        {
            switch(k)
            {
              case 0:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Name:\"");
                break;
              case 1:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Purpose:\"");
                break;
              case 2:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Arguments:\"");
                break;
              case 3:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Output:\"");
                break; 
              case 4:
                print_comment_msg(comment_start, 
                                  "\"function\"", "\"Modifies:\"");
                break;
              case 5:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Returns:\"");
                break;
              case 6:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Assumptions:\"");
                break;
	      case 7:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Bugs:\"");
                break;
	      case 8:
                print_comment_msg(comment_start,
                                  "\"function\"", "\"Notes:\"");
                break;
              default:
                break;
            }
        }
    }
}
