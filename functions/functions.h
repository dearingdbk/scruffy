/*
 * File:     functions.h
 * Author:   Bruce Dearing 100036623
 * Date:     30/11/2013
 * Version:  1.1
 * Purpose:  Header file to define functions common to a  number of 
 *           components of the C style checker.
 * 
 * Mods:     2014/09/01 Jim Diamond made some string args "const",
 *           added prototype for print_magic_number().
 */

#ifndef FUNCTIONS_H
#define FUNCTIONS_H

void append(int line, char * str, int len);

const char * first_non_white(const char * str);

char * fix_string(char * string);

void print_bad_ident(int line, int column, const char * str);

void print_comment_msg(int line, const char * type, const char * name);

void print_magic_number(int line, int column, const char * str);

void print_msg(int line, int column, char * str);

void reset_text();

#endif
