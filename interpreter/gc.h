/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Garbage-collection.
 */

#ifndef LISP_GC_H
#define LISP_GC_H

extern int lispgc_running;
extern lispptr lispgc_save_stack;

/* List element marks. */
extern char lispgc_listmarks[NUM_LISTNODES_TOTAL >> 3];
extern char lispgc_atommarks[NUM_ATOMS >> 3];

extern lispptr lispgc_cons;
extern lispptr lispgc_car;
extern lispptr lispgc_cdr;

extern void lispgc_trace_object (lispptr);
extern void lispgc_force (void);
extern void lispgc_force_user (void);
extern void lispgc_init (void);

extern void lispgc_push (lispptr);
extern void lispgc_pop (void);
extern void lispgc_retval (lispptr);

extern void lispgc_print_stats (void);

#endif
