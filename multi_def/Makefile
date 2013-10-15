CFLAGS = -o


parser: lex.yy.c
	gcc $(CFLAGS) parser lex.yy.c multi_def.tab.c -lfl

lex.yy.c: multi_def.tab.h
	lex multi_def.l

multi_def.tab.h: 
	bison -d -v multi_def.y

clean:
	rm lex.yy.c multi_def.tab.* multi_def.output parser
