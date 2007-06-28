/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Argument-related section
 */

#ifndef LISP_ARGUMENTS_H
#define LISP_ARGUMENTS_H

extern void lisparg_get2 (lispptr *car, lispptr *cdr, lispptr args);
extern lispptr lisparg_get (lispptr args);

extern void lisparg_expand (lispptr *rvars, lispptr *rvals,
                            lispptr argdef, lispptr args,
                            bool do_argeval);

extern void lisparg_init (void);

/* Return atom with same symbol in keyword package. */
extern void lisparg_apply_keyword_package (lispptr atom);

extern lispptr lisp_atom_rest;

#endif 	/* #ifndef LISP_ARGUMENTS_H */
