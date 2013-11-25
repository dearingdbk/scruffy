/**
*   ANSI C grammar, Lex specification
*/

/*
 * File:     A2P1.c
 * Author:   Jim Diamond   000123456
 * Date:     2011/09/12
 * Version:  1.0
 *
 * Purpose:
 * ...
 */


%e  1019
%p  2807
%n  371
%k  284
%a  1213
%o  1117


BG  {WS}*[*]?{WS}
DD  [0-3]?[0-9]
MM  ((0[1-9])|(1[0-2|])|([0-9]))
YY  (20|19)?[0-9]{2}
DT  (({YY}{SP}{MM}{SP}{DD})|({DD}{SP}{MM}{SP}{YY})|({MM}{SP}{DD}{SP}{YY}))
SP  [/\-. ]
FN  [a-zA-Z_0-9]+\.(c|h)
SN  [1][0-9]{8}
NM  [a-z,\.A-Z\'\-]+
TN  {NM}{WS}{NM}
BN  ({SN}{WS}+{TN}|{TN}{WS}+{SN})
WS  [ \t\v\f\n]
F   ((F|f)(ile:|ile))
A   (A|a)
TH  (uthor:|uthor)
RG  (rguments:|rguments)
SS  (ssumptions|ssumptions)
O   ((O|o)(utput:|utput))
D   ((D|d)(ate:|ate))
R   ((R|r)(eturns:|eturns))
B   ((B|b)(ugs:|ugs))
N   (N|n)
ME  (ame:|ame)
OT  (otes:|otes)
V   ((V|v)(ersion:|ersion))
P   ((P|p)(urpose:|urpose))
M   ((M|m)(odifies:|odifies))

%{
#include <stdio.h>
#include "check_comments.tab.h"
int comment_start;

%}


/*
 * Parser options
 *
 * yylineno: The %yylineno option tells flex to define an integer
 * variable called yylineno and to maintain the current line
 * number in it. Every time the scanner reads a '\n', it 
 * increments yylineno, and if the scanner backs up over
 * a '\n', it decrements it.
 */
         
%option yylineno

%x COMMENT


%%
"/*"                      { comment_start = yylineno; 
                            BEGIN(COMMENT); 
                            return(START_COMMENT); 
                          }
"//".*                    { /* consume //-comment */ }
<COMMENT>"*/"             { BEGIN(INITIAL); return(END_COMMENT);}
<COMMENT>\n               { }
<COMMENT>^{BG}{F}{WS}+{FN}     { return(FILE_LBL);}
<COMMENT>^{BG}{A}{TH}{WS}+{BN} { return(AUTHOR); }
<COMMENT>^{BG}{V}              { return(VERSION); }
<COMMENT>^{BG}{D}{WS}+{DT}     { return(DATE); }
<COMMENT>^{BG}{P}              { return(PURPOSE);}
<COMMENT>^{BG}{N}{ME}          { return(NAME); }
<COMMENT>^{BG}{A}{RG}          { return(ARGUMENTS); }
<COMMENT>^{BG}{O}              { return(OUTPUT); }
<COMMENT>^{BG}{M}              { return(MODIFIES); }
<COMMENT>^{BG}{R}              { return(RETURNS); }
<COMMENT>^{BG}{A}{SS}          { return(ASSUMPTIONS); }
<COMMENT>^{BG}{B}              { return(BUGS); }
<COMMENT>^{BG}{N}{OT}          { return(NOTES); }
<COMMENT>[^*\n]|.         { }
    /*{L}{A}*					{ return check_type(); }*/

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }
%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

