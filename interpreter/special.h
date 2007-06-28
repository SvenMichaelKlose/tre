/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in special forms.
 */

#ifndef LISP_SPECIAL_H
#define LISP_SPECIAL_H

extern bool lispeval_is_return (lispptr);
extern bool lispeval_is_go (lispptr);
extern bool lispeval_is_jump (lispptr);

extern char *lisp_special_names[];

extern lispptr lisp_atom_go;
extern lispptr lisp_atom_return_from;

extern lispptr lispspecial (lispptr func, lispptr expr);
extern void lispspecial_init (void);

#endif	/* #ifndef LISP_SPECIAL_H */
