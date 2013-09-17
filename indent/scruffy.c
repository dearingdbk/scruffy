/*
 * File:     scruffy.c
 * Author:   Bruce Dearing   100036623
 * Date:     2012/10/06
 * Version:  1.0
 *
 * Purpose:  Implements C Style Checker.
 */

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#define POPEN_SZ 1024

int set_keys();
int e_crypt(uint16_t * input);
int d_crypt(uint16_t * input);
uint8_t GF_mult(uint8_t x, uint8_t y);
uint16_t mix_col(uint16_t input, int a, int b);

uint8_t rotate(uint8_t);
uint8_t sub(uint8_t);


/* GLOBALS */

uint16_t key_zero = 0;
uint16_t key_one = 0;
uint16_t key_two = 0;

int
main(int argc, char **argv)
{

    uint16_t input = 0;
    int flag;			// Flag denotes whether encryption or decryption.

    while ((flag = getopt(argc, argv, "gkblr")) != -1)
    {
        switch (flag)
	    {
	      case 'g':
	      // GNU Style.
	      get_base_val();
	      break;

	      case 'k':
	      // Kern and Ritchie Style.
	      break;

	      case 'b':
	      // Berkely Style.
	      break;

	      case 'l':
	      // Linux Headers Style.
	      break;

	      case 'r':
	      // Rick Giles Style.
	      break;

	      case '?':
	      // Total Mystery output error message.  
	      break;

        }
    }

    return(EXIT_SUCCESS);
}

int
get_base_val()
{
    fred fret;
    double freq;
    int numCPU;
    FILE *stream_p;
    char path[POPEN_SZ];

    /* Open the command for reading. */

    char *linux_style = "indent --no-blank-lines-after-declarations "
                        "--blank-lines-after-procedures "
                        "--no-blank-lines-after-commas "
                        "--break-before-boolean-operator "
                        "--honour-newlines "
                        "--braces-on-if-line "
                        "--braces-on-func-def-line "
                        "--comment-indentation33 "
                        "--declaration-comment-column33 "
                        "--no-comment-delimiters-on-blank-lines "
                        "--cuddle-else "
                        "--continuation-indentation4 "
                        "--case-indentation0 "
                        "--line-comments-indentation0 "
                        "--declaration-indentation1 "
                        "--dont-format-first-column-comments "
                        "--indent-level8 "
                        "--parameter-indentation0 "
                        "--line-length80 "
                        "--continue-at-parentheses "
                        "--no-space-after-parentheses "
                        "--no-space-after-function-call-names "
                        "--dont-break-procedure-type "
                        "--space-after-if "
                        "--space-after-for "
                        "--space-after-while "
                        "--no-space-after-casts "
                        "--dont-star-comments "
                        "--swallow-optional-blank-lines "
                        "--dont-format-comments "
                        "--else-endif-column33 "
                        "--space-special-semicolon "
                        "--tab-size8 "
                        "--indent-label1 "
                        "scruffy.c -o out.out";
    char *gnu_style = "indent -gnu scruffy.c -o out.out";
    char *kern_and_ritchie = "indent -kr scruffy.c -o out.out";

    stream_p = popen(kern_and_ritchie, "r");
    if(stream_p == NULL){
        printf("Failed to run command\n");
        exit(EXIT_FAILURE);
    }

    if (fgets(path, POPEN_SZ, stream_p) == NULL)
    {
        printf("INDENT worked without errors.\n");
        exit(EXIT_SUCCESS);
    }


    /* close */
    pclose(stream_p);
    return 1;
}
