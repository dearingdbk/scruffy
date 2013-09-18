CFLAGS = -o

remove_single_comments: lex.yy.c
	gcc $(CFLAGS) remove_single_comments lex.yy.c -lfl

lex.yy.c:
	lex remove_single_comments.l
