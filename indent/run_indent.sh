#! /bin/sh

cat $1 | ./remove_single_comments > test.c

indent --no-blank-lines-after-declarations\
       --blank-lines-after-procedures\
       --no-blank-lines-after-commas\
       --break-before-boolean-operator\
       --braces-after-if-line\
       --brace-indent0\
       --braces-after-struct-decl-line\
       --comment-indentation33\
       --declaration-comment-column33\
       --dont-cuddle-else\
       --cuddle-do-while\
       --continuation-indentation4\
       --case-indentation2\
       --case-brace-indentation0\
       --leave-optional-blank-lines\
       --continue-at-parentheses\
       --break-before-boolean-operator\
       --indent-level4\
       --honour-newlines\
       --space-after-cast\
       --line-comments-indentation1\
       --declaration-indentation0\
       --no-space-after-function-call-names\
       --procnames-start-lines\
       --space-after-for\
       --space-after-while\
       --struct-brace-indentation0\
       --space-special-semicolon\
       --no-tabs\
       --format-first-column-comments\
       --comment-delimiters-on-blank-lines\
       -fca\
       --start-left-side-of-comments\
       --indent-label0\
       test.c -o test.out


diff \
       --old-line-format='< %l
' \
       --new-line-format='> %l
' \
       --old-group-format='%df%(f=l?:,%dl)d%dE
%<' \
       --new-group-format='%dea%dF%(F=L?:,%dL)
%>' \
       --changed-group-format='Line %df:
%<---
%>
' \
       --unchanged-group-format="" \
       -B -Z --suppress-blank-empty test.c test.out

exit 1
#--changed-group-format='%df%(f=l?:,%dl)c%dF%(F=L?:,%dL)
