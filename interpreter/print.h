/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Expression printing.
 */

#ifndef LISP_PRINT_H
#define LISP_PRINT_H

extern lispptr lispprint_highlight;

extern void lispprint (lispptr);

extern lispptr lispprint_builtin_princ (lispptr);

#endif /* #ifndef LISP_PRINT_H */
