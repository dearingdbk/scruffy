/** INCLUDE FILES **/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "y.tab.h"


/** DEFINITIONS **/
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
#define YYERROR_VERBOSE

/** GLOBAL VARIABLES **/
int case_cnt = 0;
int in_switch = 0;
int cur_line_num = 0;
int default_hit = 0;

/** MACRO DEFINITIONS **/
#define CASE_CNT if (in_switch)case_cnt++;\
                 cur_line_num = yylloc.first_line;

#define ENTER_SWITCH cur_line_num = yylloc.first_line;\
                     in_switch = yyloc.first_line;

#define DEFAULT_CNT if (in_switch)default_hit = 1;\
                    if (case_cnt)\
                    {\
                        printf("%d: Switch statement case Fall Through.\n"\
                               , cur_line_num);\
                    }\
                    cur_line_num = yyloc.first_line;

#define SWITCH_BREAK if (in_switch && !default_hit) case_cnt--;

#define EXIT_SWITCH 
