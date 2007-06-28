/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#include "util.h"

#include <stdio.h>

float 
valuetofloat (char *val)
{   
    char    c;
    int     min;
    int     corr = 0;
    float   ret = 0;

    if (*val == '-') {
        min = -1;
        val++;
    } else
        min = 1;

    while ((c = *val++) != 0) {
        if (corr)
	   corr *= 10;
        if (c == '.') {
	    corr = 1;
	    continue;
        }

        ret *= 10;
        ret += c - '0';
    }

    return ret / (corr ? corr : 1) * min;
}

void
printnl ()
{
    printf ("\n");
}
