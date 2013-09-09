CFLAGS = -o


parser: lex.yy.c
	gcc $(CFLAGS) parser lex.yy.c y.tab.c -lfl

lex.yy.c: y.tab.h
	lex lex.l

y.tab.h: required.h 
	yacc -d -v yacc.y
