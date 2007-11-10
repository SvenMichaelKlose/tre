/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Garbage collection.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "gc.h"
#include "eval.h"
#include "error.h"
#include "thread.h"
#include "util.h"
#include "array.h"
#include "env.h"
#include "diag.h"
#include "string.h"
#include "alloc.h"
#include "symbol.h"
#include "xxx.h"
#include "special.h"
#include "image.h"

#include <stdio.h>
#include <string.h>

/* List element marks. */
char tregc_listmarks[NUM_LISTNODES_TOTAL >> 3];
char tregc_atommarks[NUM_ATOMS >> 3];

treptr tregc_car;
treptr tregc_cdr;
treptr tregc_save_stack;
treptr tregc_retval_current;

bool tregc_running;

/* Put expression on stack of expressions that should not be removed by the
 * garbage collector. Atoms are ignored.
 */
void
tregc_push (treptr expr)
{
    TRELIST_PUSH(tregc_save_stack, expr);
}

void
tregc_pop ()
{
#ifdef TRE_DIAGNOSTICS
    if (tregc_save_stack == treptr_nil)
		treerror_internal (treptr_invalid, "GC save stack underflow");
#endif

    TRELIST_POP(tregc_save_stack);
}

/*
 * Save value during GC. One at a time.
 */
void
tregc_retval (treptr retval)
{
    tregc_retval_current = retval;
}

/*
 * Mark expression. Ignore CAR elements.
 */
void
tregc_trace_expr_toplevel (treptr expr)
{
    while (expr != treptr_nil) {
        TRE_UNMARK(tregc_listmarks, expr);
		expr = _CDR(expr);
    }
}

void tregc_trace_atom (treptr);

/*
 * Mark expression or tree.
 */
void
tregc_trace_expr (treptr p)
{
    treptr i;

    _DOLIST(i, p) {
        /* Avoid circular trace. */
        if (TRE_GETMARK(tregc_listmarks, i) == FALSE)
	    	return;

        TRE_UNMARK(tregc_listmarks, i);

        tregc_trace_object (_CAR(i));

        if (TREPTR_IS_EXPR(_CDR(i)) == FALSE) {
            tregc_trace_object (_CDR(i));
	    	return;
		}
    }
}

/* Mark object. */
void
tregc_trace_object (treptr p)
{
    if (TREPTR_IS_EXPR(p))
        tregc_trace_expr (p);
    else
        tregc_trace_atom (p);
}

/* Mark array. */
void
tregc_trace_array (treptr arr)
{
    struct tre_atom  *atom = TREPTR_TO_ATOM(arr);
    treptr  	      *i = atom->detail;
    unsigned          size = TREARRAY_SIZE(arr);

    /* Mark dimension list. */
    tregc_trace_expr (atom->value);

    /* Mark elements in array. */
    while (size--)
		tregc_trace_object (*i++);
}

/* Mark expressions bound to atoms. */
void
tregc_trace_atom (treptr a)
{
    struct tre_atom  *atom = TREPTR_TO_ATOM(a);
    unsigned  ai = TREPTR_INDEX(a);

    /* Avoid circular trace. */
    if (TRE_GETMARK(tregc_atommarks, ai) == FALSE)
		return;
    TRE_UNMARK(tregc_atommarks, ai);

    switch (atom->type) {
        case ATOM_FUNCTION:
        case ATOM_MACRO:
	    	tregc_trace_object ((treptr) atom->detail);
	    	break;

        case ATOM_ARRAY:
	    	tregc_trace_array (a);
	    	break;
    }
    tregc_trace_object (atom->value);
    tregc_trace_object (atom->fun);
    tregc_trace_object (atom->binding);
}

void
tregc_mark_non_internal ()
{
    /* Initialise mark map, */
    memset (tregc_listmarks, -1, sizeof (tregc_listmarks));
    memset (tregc_atommarks, -1, sizeof (tregc_atommarks));

    tregc_trace_object (treptr_universe);
    tregc_trace_object (treimage_initfun);
}

void
tregc_mark (void)
{
    tregc_mark_non_internal ();

    tregc_trace_expr_toplevel (TRECONTEXT_FUNSTACK());

    /* Mark temporarily untraceable objects. */
    tregc_trace_object (tregc_save_stack);
    tregc_trace_object (tregc_retval_current);

    /* Mark bookkeeping lists. */
    tregc_trace_expr_toplevel (tre_lists_free);
    tregc_trace_expr_toplevel (tre_atoms_free);
    tregc_trace_expr_toplevel (tre_numbers_free);

    tregc_trace_atom (tre_atom_evaluated_go);
    tregc_trace_atom (tre_atom_evaluated_return_from);
}
 
/* Remove all unmarked cons. */
void
tregc_sweep (void)
{
    unsigned  i;
    unsigned  j;
    unsigned  idx;
    char  c;

    /* Free marked atoms.
     *
     * Atoms must be freed first, so they can remove their internal conses.
     */
    DOTIMES(i, sizeof (tregc_atommarks)) {
		c = 1;
		DOTIMES(j, 8) {
	    	if (tregc_atommarks[i] & c) {
	        	idx = (i << 3) + j;
				if (TREPTR_TO_ATOM(idx)->type != ATOM_UNUSED)
	            	treatom_remove (TYPEINDEX_TO_TREPTR(TREATOM_TYPE(idx), idx));
            }

	    	c <<= 1;
        }
    }

    /* Free marked list elements. */
    DOTIMES(i, sizeof (tregc_listmarks)) {
        c = 1;
		DOTIMES(j, 8) {
	    	if (tregc_listmarks[i] & c) {
	        	idx = (i << 3) + j;
	        	trelist_free (idx);
            }

	    	c <<= 1;
        }
    }
}

void
tregc_pass (void)
{
    tregc_running = TRUE;
    tregc_mark ();
    tregc_sweep ();
    tregc_running = FALSE;
}

void
tregc_force ()
{
    if (tregc_running)
		return;

#if TRE_VERBOSE_GC
    printf ("before gc");
    tregc_print_stats ();
#endif

    tregc_pass ();

#ifdef TRE_VERBOSE_GC
    printf (" after gc");
    tregc_print_stats ();
#endif

}

void
tregc_force_user ()
{
    if (tregc_running)
		return;

    printf ("before gc");
    tregc_print_stats ();

    tregc_pass ();

    printf (" after gc");
    tregc_print_stats ();
}

void
tregc_print_stats ()
{
    unsigned c[ATOM_MAXTYPE + 1];
    unsigned i;
    unsigned atoms;

    for (i = 0; i <= ATOM_MAXTYPE; i++)
        c[i] = 0;

    for (atoms = i = 0; i < NUM_ATOMS; i++)
        if (tre_atoms[i].type != ATOM_UNUSED) {
            atoms++;
            c[(unsigned) tre_atoms[i].type]++;
        }

    printf (": %d cons, %d atoms "
            "(%d var, %d num, %d arr, %d str, "
            "%d fun, %d mac, %d usr, %d pkg, %d blt, %d spc).\n",
            trelist_num_used,
            atoms,
            c[ATOM_VARIABLE], c[ATOM_NUMBER], c[ATOM_ARRAY], c[ATOM_STRING],
            c[ATOM_FUNCTION], c[ATOM_MACRO], c[ATOM_USERSPECIAL],
            c[ATOM_PACKAGE], c[ATOM_BUILTIN], c[ATOM_SPECIAL]);
    fflush (stdout);
}

void
tregc_init ()
{
    tregc_running = FALSE;
    tregc_save_stack = treptr_nil;
    tregc_retval_current = treptr_nil;
    tregc_car = treptr_nil;
    tregc_cdr = treptr_nil;
}
