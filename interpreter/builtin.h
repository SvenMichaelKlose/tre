/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#ifndef TRE_BUILTIN_H
#define TRE_BUILTIN_H

extern char *tre_builtin_names[];
extern treevalfunc_t treeval_xlat_builtin[];

extern treptr trebuiltin (treptr func, treptr expr);

#endif	/* #ifndef TRE_BUILTIN_H */
