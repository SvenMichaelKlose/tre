/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Garbage-collection.
 */

#ifndef TRE_GC_H
#define TRE_GC_H

extern int tregc_running;
extern treptr tregc_save_stack;

/* List element marks. */
extern char tregc_listmarks[NUM_LISTNODES_TOTAL >> 3];
extern char tregc_atommarks[NUM_ATOMS >> 3];

extern treptr tregc_car;
extern treptr tregc_cdr;

extern void tregc_trace_object (treptr);
extern void tregc_mark_non_internal (void);
extern void tregc_force (void);
extern void tregc_force_user (void);
extern void tregc_init (void);

extern void tregc_push (treptr);
extern void tregc_pop (void);
extern void tregc_retval (treptr);

extern void tregc_print_stats (void);

#define TREGC_ALLOC_ATOM(index)	TRE_UNMARK(tregc_atommarks, index)
#define TREGC_ALLOC_CONS(index)	TRE_UNMARK(tregc_listmarks, index)

#endif
