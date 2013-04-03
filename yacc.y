%{

/*
 * File:     yacc.y
 * Author:   Bruce Dearing   100036623
 * Date:     2012/21/11
 * Version:  1.0
 *
 * Purpose:  YACC Grammar to parse tokens received from the lex scanner lex.l
 *           Program works from command line input either through directing a
 *           file into standard input or manual entry.
 *           ./parser < sometext.txt
 *           If Program is run though manual entry the input can be stopped 
 *           via ^D for Mac/Linux distros, and ^Z for Windows.
 * Output:   Outputs to terminal VALID INPUT RECEIVED on parsing completely
 *           valid input. and error: syntax error, unexpected TOKENID, expecting TOKENID
 *           
 *          Creates a LALR(1)  Parser - for the grammer M.
 * 
 * M:        <system goal>      -> <program> $
 *           <program>          -> begin <statement list>  end
 *           <statement list>   -> <statement> <statement tail> 
 *           <statement tail >  -> < statement > <statement tail>
 *                               |  &Lambda;  
 *           <statement>        -> Id : = <expression>;
 *                               | read ( <id list>) ; 
 *                               | write ( <expr list> ) ;
 *           <id list >         -> Id <id tail >
 *           <id tail>          -> , Id <id tail>
 *                               | &Lambda;
 *          <expr list>         -> <expression> <expr tail>
 *          <expr tail >        -> , <expression> <expr tail>
 *                               | &Lambda;  
 *          <expression>        -> <primary> <primary tail> 
 *          <primary tail>      -> <add op> <primary> <primary tail>
 *                               | &Lambda;  
 *                               | (<expression>) 
 *          <primary>           -> Id
 *                               | INTLIT
 *          <add op>            -> +
 *                               | -  
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h" 
#define YYERROR_VERBOSE

void yyerror(const char *str)
{
    fprintf(stderr, "ERROR line %d: %s\n", yylloc.first_line, str);
}
 
int yywrap()
{
    return 1;
} 
  
main()
{
   yyparse();
} 

%}

%token      ID        /* variable name */
%token      READ      /* read   */
%token      WRITE     /* write  */
%token      BEG       /* begin  */
%token      END       /* end    */
%token      INTLIT    /* [0-9]+ */
%token      COLON     /*   :    */
%token      EQUAL     /*   =    */
%token      SEMI      /*   ;    */
%token      DONE      /* EOF or $ */
%token      LPAR      /*   (    */
%token      RPAR      /*   )    */
%token      COMMA     /*   ,    */
%token      PLUS      /*   +    */
%token      MINUS     /*   -    */

%locations
%start      systemgoal

%%


systemgoal      : program DONE{ printf("VALID INPUT RECEIVED\n");  return 0;}
                ;

program         :  BEG  statementlist  END
           ;

statementlist 	:  statement statementtail  
      		;

statementtail   :     /*  empty  */
                |   statement statementtail
                ;

statement       :    ID COLON EQUAL expression SEMI
                |    READ LPAR idlist RPAR SEMI
                |    WRITE LPAR  exprlist RPAR SEMI
                ;

idlist          :    ID idtail
                ;

idtail          :     COMMA ID idtail
                |     /* empty */
                ;

exprlist        :    expression exprtail
                ;

exprtail        :    COMMA expression exprtail
                |    /* empty */ 
                ;

expression      :    primary primarytail
                ;

primarytail     :   addop primary primarytail
                |   LPAR expression RPAR
                |   /* empty */
                ;

primary         : ID
                | INTLIT
                ;

addop           : PLUS
                | MINUS
                ;
