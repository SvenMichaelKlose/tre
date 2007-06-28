/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#ifndef LISP_XXX_H
#define LISP_XXX_H

#define RETURN_NIL(x)	    if (x == lispptr_nil) return lispptr_nil;
#define RETURN_IF_NULL(x)   if (x == NULL) return;
#define RETURN_IF_NIL(x)    if (x == lispptr_nil) return;

#endif	/* #ifndef LISP_XXX_H */
