/**
*   ANSI C grammar, Lex specification
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
Q   [A-Z_]
QZ  [A-Z_0-9()]

%{

/* START Include files. */
#include <stdio.h>
#include "y.tab.h"
/* END Include files. */

/* START Definitions. */
#define NUM_HASH 9997
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
/* END Definitions. */


void yyerror(const char *);  /* prints grammar violation message */
extern int sym_type(const char *);  /* returns type from symbol table */
static void comment(void);
static int check_type(void);
char* fix_string(char* str);

#define sym_type(identifier) IDENTIFIER /* with no symbol table, fake it */

struct symbol
{
    char *name;
    int flag;
    int line_num;
    struct symbol *next;
};
/*
struct entry 
{
    struct entry *next;
    int flag;
    int line_num;
};
*/
 struct symbol symbol_table[NUM_HASH];
 struct symbol *lookup(char* str);
 void add_entry(int line_num, int flag, char* str);
 static unsigned symhash(char *sym);
%}


%option yylineno

/* START Exclusive Start State definitions. */
%x COMMENT
%x INCLUDE
%x DEFINE
%s TYPE_DEF
%x STRKT
/* END Exclusive Start State definitions. */

%%

^"#"[ \t]*"include"     { BEGIN(INCLUDE); }
<INCLUDE>.
<INCLUDE>\n             { BEGIN(INITIAL); }

^"#"[ \t]*"define"      { BEGIN(DEFINE); }
<DEFINE>[^\\]\n         { BEGIN(INITIAL); }
<DEFINE>.|\n         

"/*"                    { BEGIN(COMMENT); }
<COMMENT>"*/"           { BEGIN(INITIAL);}
<COMMENT><<EOF>>        { printf("%d: Unterminated comment\n",yylineno); return EOF; }
<COMMENT>([^*]|\n)+|.
"//".*                  { printf("%d: // comments are not portable C89 code, replace with /* ... */\n", yylineno); }

<TYPE_DEF>[a-zA-Z_0-9]+";"$        { add_entry(yylineno, TYPEDEF_NAME, yytext); BEGIN(INITIAL); unput(';');}

"auto"  				{ return(AUTO); }
"break"					{ return(BREAK); }
"case"					{ return(CASE); }
"char"					{ return(CHAR); }
"const"					{ return(CONST); }
"continue"				{ return(CONTINUE); }
"default"				{ return(DEFAULT); }
"do"					{ return(DO); }
"double"				{ return(DOUBLE); }
"else"					{ return(ELSE); }
"enum"					{ return(ENUM); }
"extern"				{ return(EXTERN); }
"float"					{ return(FLOAT); }
"for"					{ return(FOR); }
"goto"					{ return(GOTO); }
"if"					{ return(IF); }
"inline"				{ return(INLINE); }
"int"					{ return(INT); }
"long"					{ return(LONG); }
"register"				{ return(REGISTER); }
"restrict"				{ return(RESTRICT); }
"return"				{ return(RETURN); }
"short"					{ return(SHORT); }
"signed"				{ return(SIGNED); }
"sizeof"				{ return(SIZEOF); }
"static"				{ return(STATIC); }
"struct"				{ return(STRUCT); }
"switch"				{ return(SWITCH); }
"typedef"				{ BEGIN(TYPE_DEF); return(TYPEDEF);}
"union"					{ return(UNION); }
"unsigned"				{ return(UNSIGNED); }
"void"					{ return(VOID); }
"volatile"				{ return(VOLATILE); }
"while"					{ return(WHILE); }
"_Alignas"                              { return ALIGNAS; }
"_Alignof"                              { return ALIGNOF; }
"_Atomic"                               { return ATOMIC; }
"_Bool"                                 { return BOOL; }
"_Complex"                              { return COMPLEX; }
"_Generic"                              { return GENERIC; }
"_Imaginary"                            { return IMAGINARY; }
"_Noreturn"                             { return NORETURN; }
"_Static_assert"                        { return STATIC_ASSERT; }
"_Thread_local"                         { return THREAD_LOCAL; }
"__func__"                              { return FUNC_NAME; }

{L}{A}*					{ return check_type(); }

{HP}{H}+{IS}?				{ return I_CONSTANT; }
{NZ}{D}*{IS}?				{ return I_CONSTANT; }
"0"{O}*{IS}?				{ return I_CONSTANT; }
{CP}?"'"([^'\\\n]|{ES})+"'"		{ return I_CONSTANT; }

{D}+{E}{FS}?				{ return F_CONSTANT; }
{D}*"."{D}+{E}?{FS}?			{ return F_CONSTANT; }
{D}+"."{E}?{FS}?			{ return F_CONSTANT; }
{HP}{H}+{P}{FS}?			{ return F_CONSTANT; }
{HP}{H}*"."{H}+{P}{FS}?			{ return F_CONSTANT; }
{HP}{H}+"."{P}{FS}?			{ return F_CONSTANT; }

({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ return STRING_LITERAL; }

"..."					{ return ELLIPSIS; }
">>="					{ return RIGHT_ASSIGN; }
"<<="					{ return LEFT_ASSIGN; }
"+="					{ return ADD_ASSIGN; }
"-="					{ return SUB_ASSIGN; }
"*="					{ return MUL_ASSIGN; }
"/="					{ return DIV_ASSIGN; }
"%="					{ return MOD_ASSIGN; }
"&="					{ return AND_ASSIGN; }
"^="					{ return XOR_ASSIGN; }
"|="					{ return OR_ASSIGN; }
">>"					{ return RIGHT_OP; }
"<<"					{ return LEFT_OP; }
"++"					{ return INC_OP; }
"--"					{ return DEC_OP; }
"->"					{ return PTR_OP; }
"&&"					{ return AND_OP; }
"||"					{ return OR_OP; }
"<="					{ return LE_OP; }
">="					{ return GE_OP; }
"=="					{ return EQ_OP; }
"!="					{ return NE_OP; }
";"					{ return ';'; }
("{"|"<%")				{ return '{'; }
("}"|"%>")				{ return '}'; }
","					{ return ','; }
":"					{ return ':'; }
"="					{ return '='; }
"("					{ return '('; }
")"					{ return ')'; }
("["|"<:")				{ return '['; }
("]"|":>")				{ return ']'; }
"."					{ return '.'; }
"&"					{ return '&'; }
"!"					{ return '!'; }
"~"					{ return '~'; }
"-"					{ return '-'; }
"+"					{ return '+'; }
"*"					{ return '*'; }
"/"					{ return '/'; }
"%"					{ return '%'; }
"<"					{ return '<'; }
">"					{ return '>'; }
"^"					{ return '^'; }
"|"					{ return '|'; }
"?"					{ return '?'; }

{WS}					{ /* whitespace separates tokens */ }
.					{ /* discard bad characters */ }

%%

int yywrap(void)        /* called at end of input */
{
    return 1;           /* terminate now */
}

/*static void comment(void)
{
    int c;

    while ((c = input()) != 0)
        if (c == '*')
        {
            while ((c = input()) == '*')
                ;

            if (c == '/')
                return;

            if (c == 0)
                break;
        }
    yyerror("unterminated comment");
}*/



static int check_type(void)
{
    struct symbol *cur_entry = lookup(yytext);

    if (cur_entry == NULL)
    {
        return EOF;
    }
    switch (cur_entry->flag)
    {
    case TYPEDEF_NAME:                /* previously defined */
        return TYPEDEF_NAME;
    case ENUMERATION_CONSTANT:        /* previously defined */
        return ENUMERATION_CONSTANT;
    default:                          /* includes undefined */
        return IDENTIFIER;
    }
}


/* Symbol Table Implementation */


void add_entry(int line_num, int flag, char* str)
{
    char *tmp = fix_string(str);
    struct symbol *new_entry;
    struct symbol *cur_entry = lookup(tmp);

    if (cur_entry == NULL)
    {
        /* exit with an error here */return ;
    }
   
    if (cur_entry->line_num == line_num)
    {
        return;
    }

    if (cur_entry->line_num == 0)
    {
        cur_entry->line_num = line_num;
        cur_entry->flag = flag;
    }
    else
    {
        new_entry->next = cur_entry->next;
        new_entry->line_num = line_num;
        new_entry->flag = flag;
        cur_entry->next = new_entry;
    }
}


static unsigned symhash(char *sym)
{
    unsigned int hash = 0;
    unsigned c;
    while(c = *sym++)
    {
        hash = c + (hash << 6) + (hash << 16) - hash;
    }
    return hash;
}


struct symbol *lookup(char* str)
{
    unsigned int index = symhash(str) % NUM_HASH;
    struct symbol *cur_entry = &symbol_table[index];
    int scount = NUM_HASH;
    /* how many have we looked at */
    while(--scount >= 0) {
        if(cur_entry->name && !strcmp(cur_entry->name, str)) return cur_entry;
        if(!cur_entry->name)
        {
            cur_entry->name = strdup(str);
            cur_entry->next = NULL;
            return cur_entry;
        }
        /* new entry */
        if(++cur_entry >= symbol_table+NUM_HASH)
        {
            cur_entry = symbol_table; /* try the next entry */
        }
    }
    fputs("symbol table overflow\n", stderr);
    abort(); /* tried them all, table is full */
}


char* fix_string(char* string)
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


