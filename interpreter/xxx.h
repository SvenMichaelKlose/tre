/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#ifndef TRE_XXX_H
#define TRE_XXX_H

#define RETURN_NIL(x)	    if (x == treptr_nil) return treptr_nil;
#define RETURN_IF_NULL(x)   if (x == NULL) return;
#define RETURN_IF_NIL(x)    if (x == treptr_nil) return;

#endif	/* #ifndef TRE_XXX_H */
