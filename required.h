/** INCLUDE FILES **/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include "y.tab.h"


/** DEFINITIONS **/
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;
#define YYERROR_VERBOSE
#define MAX_NESTED 10

/** GLOBAL VARIABLES **/
int in_switch[MAX_NESTED] = {0};
int case_cnt[MAX_NESTED];
int default_hit[MAX_NESTED];
int pos = -1;
int cur_line_num = 0;


/** MACRO DEFINITIONS **/
#define CASE_CNT if (in_switch[pos])case_cnt[pos]++;\
                 cur_line_num = yylloc.first_line;

#define ENTER_SWITCH pos++; cur_line_num = yylloc.first_line;\
                     in_switch[pos] = yyloc.first_line;\
                     case_cnt[pos] = 0;\
                     default_hit[pos] = 0;

#define DEFAULT_CNT if (in_switch[pos])default_hit[pos] = 1;\
                    if (case_cnt[pos])\
                    {\
                        printf("%d: Switch statement case Fall Through.\n"\
                               , cur_line_num);\
                        case_cnt[pos]--;\
                    }\
                    cur_line_num = yyloc.first_line;

#define SWITCH_BREAK if (pos >= 0 && in_switch[pos])\
                     {\
                         if (default_hit[pos] != 1) case_cnt[pos]--;\
                         else default_hit[pos] = 2;\
                     }

#define EXIT_SWITCH  if (case_cnt[pos] > 0)\
                     {\
                         printf("%d: Switch statement case Fall Through.\n"\
                                 , cur_line_num);\
                     }\
                     if (default_hit[pos] != 2)\
                     {\
                         printf("%d: Switch statement missing a default case.\n"\
                                 , in_switch[pos]);\
                     }\
                     in_switch[pos] = 0;\
                     pos--;


