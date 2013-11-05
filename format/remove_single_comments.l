/*
 * File:     remove_single_comments.l
 * Author:   Bruce Dearing   100036623
 * Date:     2013/18/09
 * Version:  1.0
 *
 * Purpose:  a Lex tokenizer which strips out single lined star comments. 
 */
%option yylineno


%%

"//".*                  /* Eat up single line comments. */
[ \t]*"/*".*"*/"        /* Strip out single line comments. */
.                       
%%

main(int argc, char **argv)
{
          yylex();
}

int yywrap(void) /* called at end of input */
{
              return 1; /* terminate now */
}
