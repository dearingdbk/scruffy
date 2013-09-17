%{

%}



%option yylineno

/* START Exclusive Start State definitions. */
%x COMMENT
/* END Exclusive Start State definitions. */

%%

[ \t]*"/*".*"*/"                    /*{ BEGIN(COMMENT); }*/
.                       { printf("%s", yytext);}
%%

main(int argc, char **argv)
{
      yylex();
}

int yywrap(void)        /* called at end of input */
{
          return 1;           /* terminate now */
}


