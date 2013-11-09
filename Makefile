
all: indentR common_errors magic_num composite_check

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
	lex -o composite/composite_check.yy.c composite/composite_check.l

composite/composite_check.tab.h:
	bison --defines=composite/composite_check.tab.h \
		--output=composite/composite_check.tab.c composite/composite_check.y 

magic_num: magicnum/magic_num.yy.c functions/functions.o
	gcc magicnum/magic_num.yy.c  functions/functions.o -lfl -o magic_num

magicnum/magic_num.yy.c:
	lex -o magicnum/magic_num.yy.c magicnum/magic_num.l

functions/functions.o:
	gcc -o functions/functions.o -c functions/functions.c

clean:
	rm -f indent/check_indent.tab.* \
		indent/check_indent.yy.c \
		format/remove_single_comments.yy.c \
		common/common_errors.tab.* \
		common/common_errors.yy.c \
		functions/functions.o  \
		composite/composite_check.yy.c \
		composite/composite_check.tab.* \
		magicnum/magic_num.yy.c

remove: clean
	rm -f indentR \
		remove_single_comments \
		common_errors \
		check_declarations \
		composite_check \
		magic_num
