/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#ifndef TRE_UTIL_H
#define TRE_UTIL_H

#define DOTIMES(iter,top) \
    for (iter = 0; iter < top; iter ++)

extern float valuetofloat (char *val);
extern void printnl (void);

#endif	/* #ifndef TRE_UTIL_H */
