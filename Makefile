
all: remove_single_comments indentR common_errors check_declarations

remove_single_comments: format/remove_single_comments.yy.c
	gcc format/remove_single_comments.yy.c -lfl \
		-o remove_single_comments 

format/remove_single_comments.yy.c:
	lex -o format/remove_single_comments.yy.c \
		format/remove_single_comments.l

indentR: indent/check_indent.yy.c
	gcc  indent/check_indent.yy.c indent/check_indent.tab.c \
		-lfl -o indentR

indent/check_indent.yy.c: indent/check_indent.tab.h 
	lex -o indent/check_indent.yy.c indent/check_indent.l

indent/check_indent.tab.h: 
	bison --defines=indent/check_indent.tab.h \
		--output=indent/check_indent.tab.c  indent/check_indent.y

common_errors: common/common_errors.yy.c
	gcc  common/common_errors.yy.c common/common_errors.tab.c \
		-lfl -o common_errors

common/common_errors.yy.c: common/common_errors.tab.h
	lex -o common/common_errors.yy.c common/common_errors.l 

common/common_errors.tab.h:
	bison --defines=common/common_errors.tab.h \
		--output=common/common_errors.tab.c common/common_errors.y

check_declarations: multi_def/multi_def.yy.c
	gcc multi_def/multi_def.yy.c multi_def/multi_def.tab.c \
		-lfl -o check_declarations

multi_def/multi_def.yy.c: multi_def/multi_def.tab.h
	lex -o multi_def/multi_def.yy.c multi_def/multi_def.l

multi_def/multi_def.tab.h:
	bison --defines=multi_def/multi_def.tab.h \
		--output=multi_def/multi_def.tab.c multi_def/multi_def.y

clean:
	rm -f indent/check_indent.tab.* \
		indent/check_indent.yy.c \
		format/remove_single_comments.yy.c \
		common/common_errors.tab.* \
		common/common_errors.yy.c \
		multi_def/multi_def.yy.c \
		multi_def/multi_def.tab.*

remove: clean
	rm -f indentR \
		remove_single_comments \
		common_errors \
		check_declarations
