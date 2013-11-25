
all: check_comments composite/composite_check.yy.c


check_comments: check_comments.yy.c functions/functions.o
	gcc check_comments.yy.c check_comments.tab.c  ../composite/\
	composite_check.yy.c ../composite/composite_check.tab.c \
		../functions/functions.o -lfl -o check_comments

check_comments.yy.c: check_comments.tab.h
	lex -o check_comments.yy.c --prefix=foo check_comments.l

check_comments.tab.h:
	bison --defines=check_comments.tab.h \
		--output=check_comments.tab.c -p foo check_comments.y 


indentR: indent/check_indent.yy.c
	gcc  indent/check_indent.yy.c indent/check_indent.tab.c \
		-lfl -o indentR

indent/check_indent.yy.c: indent/check_indent.tab.h 
	lex -o indent/check_indent.yy.c indent/check_indent.l

indent/check_indent.tab.h: 
	bison --defines=indent/check_indent.tab.h \
		--output=indent/check_indent.tab.c  indent/check_indent.y

common_errors: common/common_errors.yy.c functions/functions.o
	gcc  common/common_errors.yy.c  \
		-lfl functions/functions.o -o common_errors

common/common_errors.yy.c:
	lex -o common/common_errors.yy.c common/common_errors.l 

composite_check: composite/composite_check.yy.c functions/functions.o
	gcc composite/composite_check.yy.c composite/composite_check.tab.c \
		functions/functions.o -lfl -o composite_check

composite/composite_check.yy.c: composite/composite_check.tab.h
	lex -o ../composite/composite_check.yy.c --prefix=pdf ../composite/composite_check.l

composite/composite_check.tab.h:
	bison --defines=../composite/composite_check.tab.h \
		--output=../composite/composite_check.tab.c -p pdf ../composite/composite_check.y 

functions/functions.o:
	gcc -o ../functions/functions.o -c ../functions/functions.c

clean:
	rm -f check_comments.yy.c \
		  check_comments.tab.*

remove: clean
	rm -f check_comments
