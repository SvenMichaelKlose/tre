/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#ifndef LISP_BUILTIN_H
#define LISP_BUILTIN_H

extern char *lisp_builtin_names[];

extern lispptr lispbuiltin (lispptr func, lispptr expr);

#endif	/* #ifndef LISP_BUILTIN_H */
