/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Diagnostic functions
 */

#ifndef TRE_DIAG_H
#define TRE_DIAG_H

#ifdef TRE_DIAGNOSTICS
	extern void trediag_init ();
	extern void trediag_chkptr (treptr);
	extern char trediag_listmarks[NUM_LISTNODES >> 3];
	extern char trediag_atommarks[NUM_ATOMS >> 3];

	extern int tre_user;

#	define CHKPTR(x) 	(trediag_chkptr (x))

#	define TREDIAG_ALLOC_ATOM(index)	TRE_UNMARK(trediag_atommarks, index)
#	define TREDIAG_ALLOC_CONS(index)	TRE_UNMARK(trediag_listmarks, index)
#	define TREDIAG_FREE_ATOM(index)	TRE_MARK(trediag_atommarks, index)
#	define TREDIAG_FREE_CONS(index)	TRE_MARK(trediag_listmarks, index)
#else
#	define CHKPTR(p)

#	define TREDIAG_ALLOC_ATOM(index)
#	define TREDIAG_ALLOC_CONS(index)
#	define TREDIAG_FREE_ATOM(index)
#	define TREDIAG_FREE_CONS(index)
#endif

extern void trediag_cons_used (treptr to);
extern void trediag_is_cons_of (treptr expr, treptr cons);

#endif
