/*
 * File:     composite_check.l
 * Author:   BD
 * Date:     2013/20/11
 * Version:  1.1
 * Purpose:  Flex tokenizer specification which supplies tokens to 
 *           composite_check parser in an effort to parse a file to 
 *           locate errors in code.
 * Bugs:     1. If a files first line contains a style violation which requires
 *              column position indication '^' before a newline has been 
 *              read the resulting code indication in the error msg 
 *              will be blank.
 *
 * Mods:     2014/09/01 Jim Diamond.  Remove some compiler warnings,
 *           do a bit of reformatting.  Fix an incorrect comment or two.
 */

%e 1019
%p 2807
%n 371
%k 284
%a 1213
%o 1117

O [0-7]
D [0-9]
NZ [1-9]
L [a-zA-Z_]
A [a-zA-Z_0-9]
H [a-fA-F0-9]
HP (0[xX])
E ([Ee][+-]?{D}+)
P ([Pp][+-]?{D}+)
FS (f|F|l|L)
IS (((u|U)(l|L|ll|LL)?)|((l|L|ll|LL)(u|U)?))
CP (u|U|L)
SP (u8|u|U|L)
ES (\\(['"\?\\abfnrtv]|[0-7]{1,3}|x[a-fA-F0-9]+))
WS [ \t\v\f]

%{

/* START Include files. */
#include <ctype.h>
#include <stdio.h>
#ifndef COMPOSITE_CHECK_TAB_H
    #define COMPOSITE_CHECK_TAB_H
    #include "composite_check.tab.h"
#endif

#include "../functions/functions.h"
/* END Include files. */


/* START Function Definitions */
static int check_type(char * str);
struct symbol * lookup(char * str);
void add_entry(int line_num, int flag, char * str);
static unsigned get_hashval(char * sym);
char linebuf[500];
/* END Function Definitions */

/* START Definitions. */
#define NUM_HASH 9997
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
                       yylloc.first_column = yycolumn; \
                       yylloc.last_column = yycolumn+yyleng-1; \
                       yycolumn += yyleng;

#define RESET(x) x = 1
/* END Definitions. */


/* START Program variables */
struct symbol
{
    char *name;
    int flag;
    int line_num;
    struct symbol *next;
};

struct symbol symbol_table[NUM_HASH];
int yycolumn = 1;

/* END Program variables */

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


/* START Exclusive Start State definitions. */
%x COMMENT
%x INCLUDE
%x DEFINE
/* END Exclusive Start State definitions. */


/* START Inclusive Start State definitions. */
%s TYPE_DEF
%s STRUCT_BLOCK
%s STRUCT
%s ENUM
%s ENUM_BLOCK
/* END Inclusive Start State definitions. */

%%

^"#"[ \t]*"include".*      { BEGIN(INCLUDE); }
<INCLUDE>.
<INCLUDE>\n                { RESET(yycolumn);  BEGIN(INITIAL); }

^"#"[ \t]*"define"         { BEGIN(DEFINE);}
<DEFINE>.|\n
<DEFINE>[^\\]\n            { RESET(yycolumn);  BEGIN(INITIAL); }

"/*"                       { BEGIN(COMMENT); }
<COMMENT>"*/"              { BEGIN(INITIAL); }
<COMMENT><<EOF>>           { printf("%d: Unterminated comment\n",yylineno);
                             return EOF; 
                           }
<COMMENT>[^*\n]+|.      
<COMMENT>\n                {  }      

"//".*                        /* Eat up single line comments. */

^"#"[ \t]*"undef".*        |
^"#"[ \t]*"if".*           |
^"#"[ \t]*"elif".*         |
^"#"[ \t]*"else".*         |
^"#"[ \t]*"endif".*        |
^"#"[ \t]*"line".*         |
^"#"[ \t]*"error".*        |
^"#"[ \t]*"pragma".*       |
^"#"                       ; /* Eat up preprocessor directives. */

<TYPE_DEF>{L}{A}*";"$      { add_entry(yylineno, TYPEDEF_NAME, yytext);
                             BEGIN(INITIAL);
                             yyless(yyleng - 1);
                           }

<STRUCT>"{"                { BEGIN(STRUCT_BLOCK);  }
<STRUCT>{L}{A}*            { add_entry(yylineno, TYPEDEF_NAME, yytext);
                             BEGIN(INITIAL);
                           }

<STRUCT_BLOCK>"}"          { BEGIN(STRUCT); }

<ENUM>;                    { BEGIN(INITIAL); }
<ENUM>"{"                  { BEGIN(ENUM_BLOCK); }
<ENUM>{L}{A}*              { add_entry(yylineno, IDENTIFIER, yytext); }

<ENUM_BLOCK>"}"            { BEGIN(ENUM); }
<ENUM_BLOCK>{L}{A}*        { add_entry(yylineno, ENUMERATION_CONSTANT, yytext);}


"auto"                     { return(AUTO); }
"bool"                     { return(BOOL); }
"break"                    { return(BREAK); }
"case"                     { return(CASE); }
"char"                     { return(CHAR); }
"const"                    { return(CONST); }
"continue"                 { return(CONTINUE); }
"default"                  { return(DEFAULT); }
"do"                       { return(DO); }
"double"                   { return(DOUBLE); }
"else"                     { return(ELSE); }
"enum"                     { BEGIN(ENUM); return(ENUM); }
"extern"                   { return(EXTERN); }
"float"                    { return(FLOAT); }
"for"                      { return(FOR); }
"goto"                     { return(GOTO); }
"if"                       { return(IF); }
"inline"                   { return(INLINE); }
"int"                      { return(INT); }
"long"                     { return(LONG); }
"register"                 { return(REGISTER); }
"restrict"                 { return(RESTRICT); }
"return"                   { return(RETURN); }
"short"                    { return(SHORT); }
"signed"                   { return(SIGNED); }
"sizeof"                   { return(SIZEOF); }
"static"                   { return(STATIC); }
"struct"                   { BEGIN(STRUCT); return(STRUCT); }
"switch"                   { return(SWITCH); }
"typedef"                  { BEGIN(TYPE_DEF); return(TYPEDEF);}
"union"                    { return(UNION); }
"unsigned"                 { return(UNSIGNED); }
"void"                     { return(VOID); }
"volatile"                 { return(VOLATILE); }
"while"                    { return(WHILE); }
"_Alignas"                 { return ALIGNAS; }
"_Alignof"                 { return ALIGNOF; }
"_Atomic"                  { return ATOMIC; }
"_Bool"                    { return BOOL; }
"_Complex"                 { return COMPLEX; }
"_Generic"                 { return GENERIC; }
"_Imaginary"               { return IMAGINARY; }
"_Noreturn"                { return NORETURN; }
"_Static_assert"           { return STATIC_ASSERT; }
"_Thread_local"            { return THREAD_LOCAL; }
"__func__"                 { return FUNC_NAME; }

{L}{A}*                    { return check_type(yytext); }

{HP}{H}+{IS}?              { return I_CONSTANT; } // HEX
{NZ}{D}*{IS}?              { return I_CONSTANT; }
"0"{O}*{IS}?               { return I_CONSTANT; } // OCTAL
{CP}?"'"([^'\\\n]|{ES})+"'" { return I_CONSTANT; }

{D}+{E}{FS}?               { return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?       { return F_CONSTANT; }
{D}+"."{E}?{FS}?           { return F_CONSTANT; }
{HP}{H}+{P}{FS}?           { return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?    { return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?        { return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+ { return STRING_LITERAL; }

"..."                      { return ELLIPSIS; }
">>="                      { return RIGHT_ASSIGN; }
"<<="                      { return LEFT_ASSIGN; }
"+="                       { return ADD_ASSIGN; }
"-="                       { return SUB_ASSIGN; }
"*="                       { return MUL_ASSIGN; }
"/="                       { return DIV_ASSIGN; }
"%="                       { return MOD_ASSIGN; }
"&="                       { return AND_ASSIGN; }
"^="                       { return XOR_ASSIGN; }
"|="                       { return OR_ASSIGN; }
">>"                       { return RIGHT_OP; }
"<<"                       { return LEFT_OP; }
"++"                       { return INC_OP; }
"--"                       { return DEC_OP; }
"->"                       { return PTR_OP; }
"&&"                       { return AND_OP; }
"||"                       { return OR_OP; }
"<="                       { return LE_OP; }
">="                       { return GE_OP; }
"=="                       { return EQ_OP; }
"!="                       { return NE_OP; }
";"                        { return ';'; }
("{"|"<%")                 { return '{'; }
("}"|"%>")                 { return '}'; }
","                        { return ','; }
":"                        { return ':'; }
"="                        { return '='; }
"("                        { return '('; }
")"                        { return ')'; }
("["|"<:")                 { return '['; }
("]"|":>")                 { return ']'; }
"."                        { return '.'; }
"&"                        { return '&'; }
"!"                        { return '!'; }
"~"                        { return '~'; }
"-"                        { return '-'; }
"+"                        { return '+'; }
"*"                        { return '*'; }
"/"                        { return '/'; }
"%"                        { return '%'; }
"<"                        { return '<'; }
">"                        { return '>'; }
"^"                        { return '^'; }
"|"                        { return '|'; }
"?"                        { return '?'; }

{WS}                       { /* white space separates tokens */ }
\n.*                       { append(yylineno, yytext, yyleng);
                             yyless(1);
                             RESET(yycolumn);
                           }
.                          { /* discard bad characters */ }


%%



/*
 * Name:        yywrap
 * Purpose:     called at the end of input, in this case we do not
                wrap, we terminate.
 * Arguments:   void.
 * Output:      none.
 * Modifies:    none.
 * Returns:     1
 * Assumptions: 
 * Bugs:        None found.
 * Notes:
 */

int
yywrap(void) /* called at end of input */
{
    return 1; /* terminate now */
}


/*
 * Name:        check_type
 * Purpose:     Checks whether an identifier has been previously 
 *              entered into the symbol table; if not add it.
 * Arguments:   str: the string containing the identifier.
 * Output:      none.
 * Modifies:    symbol_table.
 * Returns:     The type (or EOF on error).
 * Assumptions: 
 * Bugs:        None found.
 * Notes:
 */

static int
check_type(char * str)
{
    struct symbol * cur_entry = lookup(str);

    if (cur_entry == NULL)
        return EOF;

    switch (cur_entry->flag)
    {
      case TYPEDEF_NAME:              /* previously defined */
        return TYPEDEF_NAME;
      case ENUMERATION_CONSTANT:      /* previously defined */
        return ENUMERATION_CONSTANT;
      default:                        /* includes undefined */
        return IDENTIFIER;
    }
}


/* Symbol Table Implementation */

/*
 * Name:        add_entry
 * Purpose:     adds an identifier to the symbol table.
 * Arguments:   line_num: the line number where the identifier was found.
 *              flag: the type of identifier located: enum, typedef, or
 *              identifier.
 *              str: the string containing the identifier.
 * Output:      None.
 * Modifies:    symbol_table.
 * Returns:     void.
 * Assumptions: 
 * Bugs:        None found.
 * Notes:
 */ 

void
add_entry(int line_num, int flag, char * str)
{
    char * rtnstr = fix_string(str);
    struct symbol * new_entry;
    struct symbol * cur_entry = lookup(rtnstr);

    if (isupper(rtnstr[0]) || isdigit(rtnstr[0]) || '_' == rtnstr[0])
        print_bad_ident(line_num, yycolumn, rtnstr);

    if (cur_entry == NULL)
    {
        fprintf(stderr, "Unable to enter value into table: %s \n", str);
        abort();
    }
   
    if (cur_entry->line_num == line_num)
        return;

    if (cur_entry->line_num == 0)
    {
        cur_entry->line_num = line_num;
        cur_entry->flag = flag;
    }
    else
    {
        new_entry = (struct symbol *)malloc(sizeof(struct symbol));
        new_entry->next = cur_entry->next;
        new_entry->line_num = line_num;
        new_entry->flag = flag;
        cur_entry->next = new_entry;
    }
}



/*
 * Name:        get_hashval
 * Purpose:     returns the hash of the entry string.
 * Arguments:   str: The string to hash and then return.
 * Output:      none
 * Modifies:    none
 * Returns:     hash of string parameter.
 * Assumptions: 
 * Bugs:        None found.
 * Notes:
 */ 

static unsigned
get_hashval(char * str)
{
    unsigned int hash = 0;
    unsigned c;

    while ((c = *str++) != 0)
        hash = c + (hash << 6) + (hash << 16) - hash;

    return hash;
}



/*
 * Name:        lookup
 * Purpose:     Searches for the existence of a symbol in the 
 *              symbol_table array.
 *		Adds this entry if not found (partially; add_entry
 *		does the rest).
 * Arguments:   str: The string to search for in the symbol_table.
 * Output:      none
 * Modifies:    The symbol table.
 * Returns:     struct symbol *.
 * Assumptions: 
 * Bugs:        none
 * Notes:
 */ 

struct symbol *
lookup(char * str)
{
    unsigned int index = get_hashval(str) % NUM_HASH;
    struct symbol * cur_entry = &symbol_table[index];
    int scount = NUM_HASH;

    while (--scount >= 0) // search though symbol_table array. 
    {
        if (cur_entry->name && !strcmp(cur_entry->name, str))
            return cur_entry;

        if (!cur_entry->name)
        {
            cur_entry->name = strdup(str);
            cur_entry->next = NULL;
            return cur_entry;
        }

        if (++cur_entry >= symbol_table + NUM_HASH)
            cur_entry = symbol_table;
    }

    fprintf(stderr, "Symbol table overflow\n");
    abort();
}
