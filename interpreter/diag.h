/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Diagnostic functions
 */

#ifndef TRE_DIAG_H
#define TRE_DIAG_H

#ifdef DIAGNOSTICS

extern int tre_user;

#define CHKPTR(p) \
    if (TREPTR_TYPE(p) > ATOM_MAXTYPE)	\
	treerror_internal (p, "illegal type in ptr")
#else
#define CHKPTR(p)
#endif

extern void trediag_cons_used (treptr to);
extern void trediag_is_cons_of (treptr expr, treptr cons);
extern unsigned trediag_atom_of (treptr);

#endif
