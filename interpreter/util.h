/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#ifndef LISP_UTIL_H
#define LISP_UTIL_H

#define DOTIMES(iter,top) \
    for (iter = 0; iter < top; iter ++)

extern float valuetofloat (char *val);
extern void printnl (void);

#endif	/* #ifndef LISP_UTIL_H */
