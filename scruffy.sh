#! /bin/sh
# File:     scruffy.sh
# Author:   Bruce Dearing   100036623
# Date:     2014/06/15
# Version:  2.0 (astyle)

# Purpose:  Main script runs the multipart process  of formatting and 
#           checking of files. Initially it creates two temp files 
#           temp_in which will contain the expanded form of the file
#           to be checked and temp_out which will contain a formatted
#           version of the file to compare against.
#           
#           use case 'sh scruffy.sh <file_to_be_checked>'
#


# GLOBAL VARIABLE DEFINITIONS
MAX_LINES=2000

# Check that an argument was supplied to the program and that it is a file.

if [ $# -eq 0 ]
    then
        echo 'No file name specified.'
        exit 1
else
    if [ ! -f $1 ]
        then
            echo 'File supplied does not exist.'
            exit 1
    fi
fi


# Check that indentR, common_errors, and composite_check exist.
# If they do not create them.

if [ ! -e indentR -o ! -e common_errors  -o ! -e composite_check \
-o ! -e check_comments ]
then
    make --quiet || { echo 'Failed to build required programs!' >&2;\
     rm -f $1; exit 1; }
    make --quiet clean

    if [ ! -e indentR -o ! -e common_errors  -o ! -e composite_check\
     -o ! -e check_comments ]
    then
        echo 'Failed to build required programs!'
        rm -f $1
        exit 1
    fi
fi

# Temp files created here. Depending on system the creation of tmp files may
# need to be altered to faciltate.

#temp_in=$(mktemp -t 'XXXXXXXXXXX.c')     #Worked in Debian based systems
#temp_out=$(mktemp -t 'XXXXXXXXXXX.out')  #Worked in Debian based systems
temp_in=`mktemp -t in.XXXXXX`             #Worked in slackware based
temp_out=`mktemp -t out.XXXXXX`           #Worked in slackware based

# Verify the tmp files were created.

if [ ! -e $temp_in -o ! -e $temp_out ]
then
    echo Unable to create tmp files.
    rm -f $1
    exit 1
fi


# Set temp_in and temp_out with un-tabbed versions of checked file.
# Piped through stream editor command to remove trailing white space.

expand $1 | sed "s/[ \t]*$//" > $temp_in
cp $temp_in $temp_out


##############################################################################
#                          FILE LENGTH CHECK                                 #
# Check that the file has less than the maximum number of lines.             #
##############################################################################

# The first line of error output will be if the file exceeds the max file
# length as determined by $MAX_LINES. Following check-styles reasoning the
# maximum number of lines a file can have is 2000.

size=`wc -l $1 | cut -d' ' -f1`  # Retrieve newline count of checked file.

if [ $size -gt $MAX_LINES ]
then
    echo $1 \\n \\nFile length is $size lines '['max allowed is $MAX_LINES']'.\
        \\n\\n
fi


##############################################################################
#                       COMMENT PORTION CHECK                                #
# Check that the file has proper indentation levels throughout.              #
##############################################################################

# check_comments validates that the file begins with a header comment 
# and function comments have the appropriate tags if included.
#
#  HEADER COMMENT                                 FUNCTION COMMENT
#   /*                                     /*
#    * File:     A2P1.c                     * Name:        my_func
#    * Author:   My Name 100123456          * Purpose:     ...
#    * Date:     2011/09/12                 * Arguments:   ...
#    * Version:  1.0                        * Output:      ...
#    *                                      * Modifies:    ...
#    * Purpose:                             * Returns:     ...
#    * ...                                  * Assumptions: ...
#    */                                     * Bugs:        ...
#                                           * Notes:       ...
#                                           */

./check_comments < $1


##############################################################################
#                       INDENTATION PORTION CHECK                            #
# Check that the file has proper indentation levels throughout.              #
##############################################################################

# Run the un-tabbed version of file through vim with commands to 
# properly indent the program file. The commands are contained in
# indent/vim_commands.scr

if [ ! `which vim` -o ! -e indent/vim_commands.scr ]
then
    rm $1 $temp_in $temp_out
    echo 'Vim not installed, or command script missing'
    exit 1
fi
vim -e -s $temp_in < indent/vim_commands.scr

# Running vim on the file also adds in tab characters for spacing
# the file is once again run through expand to un-tabify the input.
# then the file is compared against the original un-tabbed version
# of the check file.
# Then that output is piped through indentR which parses the diff output
# into a usable form.
# the diff setup here is similar to the normal output from diff with a few
# exceptions the line format has been edited to output only the text, and
# an end statement "$$$" has been added to signal to indentR that it has 
# reached the end of output for an instance of difference.

expand $temp_in | diff \
    --old-line-format='%l
' \
    --new-line-format='%l
' \
    --old-group-format='%df%(f=l?:,%dl)d%dE
%<' \
    --new-group-format='%dea%dF%(F=L?:,%dL)
%>' \
    --changed-group-format='%df%(f=l?:,%dl)c%dF%(F=L?:,%dL)
%<---
%>$$$
' \
    --unchanged-group-format="" \
    $temp_out - | ./indentR



##############################################################################
#                          COMMON ERROR / STYLE CHECKS                       #
# Checks document for common coding errors and style errors. (in progress)   #
##############################################################################


# common_errors checks for white space violations, bracket 
# placement, etc.

./common_errors < $1

# composite_check has a number of checks it performs against a modified 
# ANSI C grammar. The code is tokenized and parsed as it normally would
# be, however, grammar rules and reductions have been added to make it 
# possible to check for:
#   - Variable declarations on a multi-variable definition statement.
#     i.e. int a, b, c = 4, d;  " c should be declared on it's own line.
#   - Switch statement common errors.
#   - Empty statements.
#   - Empty code blocks.
#   - Naming conventions of variables, structs, and functions.
#        i.e. int a, numOfCats, num_dogs; is ok 
#             int A, NumOfCats, Num_dogs; is not.
#   - Line length > 79.

./composite_check < $1


##############################################################################
#                           FORMAT PORTION                                   #
# Check that the file has the proper the formatting throughout.              # 
##############################################################################


# Run the file through expand again to remove tabs. That output is then 
# piped through two stream editor commands which work to strip out 
# single line comments. This allows for single line comments in code,
# and enables the check of 
# multi-line comments for proper spacing and format.

expand $1 | sed 's?//.*??g' | sed 's?/\*.*\*/??g' > $temp_in
if [ `which indent` ]
then
    indent --no-blank-lines-after-declarations\
        --blank-lines-after-procedures\
        --no-blank-lines-after-commas\
        --break-before-boolean-operator\
        --braces-after-if-line\
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
        --no-space-after-casts\
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
        --format-all-comments\
        --start-left-side-of-comments\
        --brace-indent0\
        --indent-label0\
        --line-length79\
        --no-space-after-parentheses\
        $temp_in -o $temp_out


    diff \
        --old-line-format='%l
' \
        --new-line-format='%l
' \
        --old-group-format=''\
        --new-group-format=''\
        --changed-group-format='%df:
%<---
%>
'\
        --unchanged-group-format=""\
        -b --suppress-blank-empty\
        $temp_in $temp_out

else
    echo 'indent program not available!'
    rm $temp_in $temp_out
    exit 1
fi

rm $temp_in $temp_out
echo Scruffy's gonna die the way he lived. Mmhm.
exit 0

