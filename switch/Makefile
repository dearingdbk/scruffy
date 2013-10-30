CFLAGS = -o


parser: lex.yy.c
	gcc $(CFLAGS) parser lex.yy.c switch_check.tab.c -lfl

lex.yy.c: switch_check.tab.h
	lex switch_check.l

switch_check.tab.h: 
	bison -d -v switch_check.y

clean:
	rm -f lex.yy.c switch_check.tab.* switch_check.output parser
