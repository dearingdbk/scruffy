/*
 * File:     functions.h
 * Author:   Bruce Dearing 100036623
 * Date:     30/11/2013
 * Version:  1.0
 * Purpose:  Header file to define functions common to a  number of 
 *           components of the C style checker.
 */

#ifndef FUNCTIONS_H
#define FUNCTIONS_H

void print_bad_ident(int line, int column, char *str);

char* trim(char *str);

void print_msg(int line, int column, char *str);

void reset_text();

void append(int line, char *str, int len);

char* fix_string(char* string);

void print_comment_msg(int line, char *type, char *name);
#endif
