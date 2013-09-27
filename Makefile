CFLAGS = -o

all: remove_single_comments indentR

remove_single_comments: remove_single_comments.yy.c
	gcc $(CFLAGS) remove_single_comments format/remove_single_comments.yy.c -lfl

remove_single_comments.yy.c:
	lex -o format/remove_single_comments.yy.c format/remove_single_comments.l

indentR: check_indent.yy.c
	gcc $(CFLAGS) indentR indent/check_indent.yy.c indent/check_indent.tab.c   -lfl

check_indent.yy.c: check_indent.tab.h 
	lex -o indent/check_indent.yy.c indent/check_indent.l

check_indent.tab.h: 
	bison --defines=indent/check_indent.tab.h --output=indent/check_indent.tab.c  indent/check_indent.y

clean:
	rm indent/check_indent.tab.h \
		indent/check_indent.tab.c \
		indent/check_indent.yy.c \
		format/remove_single_comments.yy.c

remove:
	rm indentR remove_single_comments
