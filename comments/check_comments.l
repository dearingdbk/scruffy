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

O   [0-7]
D   [0-9]
NZ  [1-9]
L   [a-zA-Z_]
A   [a-zA-Z_0-9]
H   [a-fA-F0-9]
HP  (0[xX])
E   ([Ee][+-]?{D}+)
P   ([Pp][+-]?{D}+)
FS  (f|F|l|L)
IS  (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP  (u|U|L)
SP  (u8|u|U|L)
ES  (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS  [ \t\v\n\f]

%{
#include <stdio.h>
#include "check_comments.tab.h"




%}

%x COMMENT


%%
"/*"                    { BEGIN(COMMENT); return(START_COMMENT); }
"//".*                  { /* consume //-comment */ }
<COMMENT>"*/"           { BEGIN(INITIAL); return(END_COMMENT);}
<COMMENT>\n             { }
<COMMENT>":"            { return(':'); }
<COMMENT>"File"         { return(FILE_LBL);}
<COMMENT>"Author"       { return(AUTHOR); }
<COMMENT>"Version"      { return(VERSION); }
<COMMENT>"Date"         { return(DATE); }
<COMMENT>"Purpose"      { return(PURPOSE);}
<COMMENT>"Name"         { return(NAME); }
<COMMENT>"Arguments"    { return(ARGUMENTS); }
<COMMENT>"Output"       { return(OUTPUT); }
<COMMENT>"Modifies"     { return(MODIFIES); }
<COMMENT>"Returns"      { return(RETURNS); }
<COMMENT>"Assumptions"  { return(ASSUMPTIONS); }
<COMMENT>"Bugs"         { return(BUGS); }
<COMMENT>"Notes"        { return(NOTES); }
<COMMENT>[^*\n]|.      { }


    /*{L}{A}*					{ return check_type(); }*/

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

