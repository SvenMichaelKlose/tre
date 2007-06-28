/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Diagnostic functions
 */

#ifndef LISP_DIAG_H
#define LISP_DIAG_H

#ifdef DIAGNOSTICS

extern int lisp_user;

#define CHKPTR(p) \
    if (LISPPTR_TYPE(p) > ATOM_MAXTYPE)	\
	lisperror_internal (p, "illegal type in ptr")
#else
#define CHKPTR(p)
#endif

extern void lispdiag_cons_used (lispptr to);
extern void lispdiag_is_cons_of (lispptr expr, lispptr cons);
extern unsigned lispdiag_atom_of (lispptr);

#endif
