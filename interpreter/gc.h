/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007,2009 Sven Klose <pixel@copei.de>
 *
 * Garbage-collection.
 */

#ifndef TRE_GC_H
#define TRE_GC_H

extern int tregc_running;
extern treptr tregc_save_stack;

/* List element marks. */
extern char tregc_listmarks[NUM_LISTNODES >> 3];
extern char tregc_atommarks[NUM_ATOMS >> 3];

extern treptr tregc_car;
extern treptr tregc_cdr;
extern treptr tregc_retval_current;

extern void tregc_trace_object (treptr);
extern void tregc_mark_non_internal (void);
extern void tregc_force (void);
extern void tregc_force_user (void);
extern void tregc_init (void);

extern void tregc_push (treptr);
extern treptr tregc_push_compiled (treptr);
extern void tregc_pop (void);
extern void tregc_retval (treptr);

extern void tregc_print_stats (void);

#define _TREGC_ALLOC_ATOM(index)	TRE_UNMARK(tregc_atommarks, index)
#define _TREGC_ALLOC_CONS(index)	TRE_UNMARK(tregc_listmarks, index)
#define _TREGC_FREE_ATOM(index)	TRE_MARK(tregc_atommarks, index)
#define _TREGC_FREE_CONS(index)	TRE_MARK(tregc_listmarks, index)

#ifdef TRE_DIAGNOSTICS
#	define TREGC_ALLOC_ATOM(index)	_TREGC_ALLOC_ATOM(index)
#	define TREGC_ALLOC_CONS(index)	_TREGC_ALLOC_CONS(index)
#	define TREGC_FREE_ATOM(index)	_TREGC_FREE_ATOM(index)
#	define TREGC_FREE_CONS(index)	_TREGC_FREE_CONS(index)
#else
#	define TREGC_ALLOC_ATOM(index)
#	define TREGC_ALLOC_CONS(index)
#	define TREGC_FREE_ATOM(index)
#	define TREGC_FREE_CONS(index)
#endif

#endif
