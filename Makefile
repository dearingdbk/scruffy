CFLAGS=-Wall -O3

all: indentR common_errors composite_check check_comments

indentR: indent/check_indent.yy.c
	gcc $(CFLAGS) indent/check_indent.yy.c \
		-lfl -o indentR

indent/check_indent.yy.c: indent/check_indent.l
	lex -o indent/check_indent.yy.c indent/check_indent.l

common_errors: common/common_errors.yy.c functions/functions.o
	gcc $(CFLAGS) common/common_errors.yy.c \
		-lfl functions/functions.o -o common_errors

common/common_errors.yy.c: common/common_errors.l
	lex -o common/common_errors.yy.c common/common_errors.l

composite_check: composite/composite_check.yy.c functions/functions.o
	gcc $(CFLAGS) composite/composite_check.yy.c \
		composite/composite_check.tab.c \
		functions/functions.o -lfl -o composite_check

composite/composite_check.yy.c: composite/composite_check.tab.h \
			composite/composite_check.l
	lex -o composite/composite_check.yy.c composite/composite_check.l

composite/composite_check.tab.h: composite/composite_check.y
	bison  -g --defines=composite/composite_check.tab.h \
		--output=composite/composite_check.tab.c \
		composite/composite_check.y 

check_comments: comments/check_comments.yy.c functions/functions.o
	gcc $(CFLAGS) comments/check_comments.yy.c \
		comments/check_comments.tab.c \
		functions/functions.o -lfl -o check_comments

comments/check_comments.yy.c: comments/check_comments.tab.h \
				comments/check_comments.l
	lex -o comments/check_comments.yy.c comments/check_comments.l

comments/check_comments.tab.h: comments/check_comments.y
	bison -g --defines=comments/check_comments.tab.h \
		--output=comments/check_comments.tab.c \
		comments/check_comments.y 

functions/functions.o: functions/functions.c functions/functions.h
	gcc $(CFLAGS) -c functions/functions.c -o functions/functions.o 

clean:
	rm -f indent/check_indent.tab.* \
		indent/check_indent.yy.c \
		format/remove_single_comments.yy.c \
		common/common_errors.tab.* \
		common/common_errors.yy.c \
		functions/functions.o \
		composite/composite_check.yy.c \
		composite/composite_check.tab.*\
		comments/check_comments.yy.c \
		comments/check_comments.tab.*

remove: clean
	rm -f indentR \
		remove_single_comments \
		common_errors \
		check_declarations \
		composite_check \
		check_comments


