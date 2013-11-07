
all: indentR common_errors magic_num complex_check


#remove_single_comments: format/remove_single_comments.yy.c
#	gcc format/remove_single_comments.yy.c -lfl \
#		-o remove_single_comments 

#format/remove_single_comments.yy.c:
#	lex -o format/remove_single_comments.yy.c \
#		format/remove_single_comments.l

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

#common/common_errors.tab.h:
#	bison --defines=common/common_errors.tab.h \
#		--output=common/common_errors.tab.c common/common_errors.y

#check_declarations: multi_def/multi_def.yy.c
#	gcc multi_def/multi_def.yy.c multi_def/multi_def.tab.c \
#		-lfl -o check_declarations

#multi_def/multi_def.yy.c: multi_def/multi_def.tab.h
#	lex -o multi_def/multi_def.yy.c multi_def/multi_def.l

#multi_def/multi_def.tab.h:
#	bison --defines=multi_def/multi_def.tab.h \
#		--output=multi_def/multi_def.tab.c multi_def/multi_def.y

complex_check: complex/complex_check.yy.c functions/functions.o
	gcc complex/complex_check.yy.c complex/complex_check.tab.c \
		functions/functions.o -lfl -o complex_check

complex/complex_check.yy.c: complex/complex_check.tab.h
	lex -o complex/complex_check.yy.c complex/complex_check.l

complex/complex_check.tab.h:
	bison --defines=complex/complex_check.tab.h \
		--output=complex/complex_check.tab.c complex/complex_check.y 

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
		complex/complex_check.yy.c \
		complex/complex_check.tab.* \
		magicnum/magic_num.yy.c

remove: clean
	rm -f indentR \
		remove_single_comments \
		common_errors \
		check_declarations \
		complex_check \
		magic_num
