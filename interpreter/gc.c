/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Garbage collection
 */

#include "lisp.h"
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
char lispgc_listmarks[NUM_LISTNODES_TOTAL >> 3];
char lispgc_atommarks[NUM_ATOMS >> 3];

lispptr lispgc_car;
lispptr lispgc_cdr;
lispptr lispgc_save_stack;
lispptr lispgc_retval_current;

bool lispgc_running;

/* Put expression on stack of expressions that should not be removed by the
 * garbage collector. Atoms are ignored.
 */
void
lispgc_push (lispptr expr)
{
    LISPLIST_PUSH(lispgc_save_stack, expr);
}

void
lispgc_pop ()
{
#ifdef LISP_DIAGNOSTICS
    if (lispgc_save_stack == lispptr_nil)
	lisperror_internal (lispptr_invalid, "GC save stack underflow");
#endif

    LISPLIST_POP(lispgc_save_stack);
}

/*
 * Save value during GC. One at a time.
 */
void
lispgc_retval (lispptr retval)
{
    lispgc_retval_current = retval;
}

/*
 * Mark expression. Ignore CAR elements.
 */
void
lispgc_trace_expr_toplevel (lispptr expr)
{
    while (expr != lispptr_nil) {
        LISP_UNMARK(lispgc_listmarks, expr);
	expr = _CDR(expr);
    }
}

void lispgc_trace_atom (lispptr);

/*
 * Mark expression or tree.
 */
void
lispgc_trace_expr (lispptr p)
{
    lispptr i;

    _DOLIST(i, p) {
        /* Avoid circular trace. */
        if (LISP_GETMARK(lispgc_listmarks, i) == FALSE)
	    return;

        LISP_UNMARK(lispgc_listmarks, i);

        lispgc_trace_object (_CAR(i));

        if (LISPPTR_IS_EXPR(_CDR(i)) == FALSE) {
            lispgc_trace_object (_CDR(i));
	    return;
	}
    }
}

/* Mark object. */
void
lispgc_trace_object (lispptr p)
{
    if (LISPPTR_IS_EXPR(p))
        lispgc_trace_expr (p);
    else
        lispgc_trace_atom (p);
}

/* Mark array. */
void
lispgc_trace_array (lispptr arr)
{
    struct lisp_atom  *atom = LISPPTR_TO_ATOM(arr);
    lispptr  	      *i = atom->detail;
    unsigned          size = LISPARRAY_SIZE(arr);

    /* Mark dimension list. */
    lispgc_trace_expr (atom->value);

    /* Mark elements in array. */
    while (size--)
	lispgc_trace_object (*i++);
}

/* Mark expressions bound to atoms. */
void
lispgc_trace_atom (lispptr a)
{
    struct lisp_atom  *atom = LISPPTR_TO_ATOM(a);
    unsigned  ai = LISPPTR_INDEX(a);

    /* Avoid circular trace. */
    if (LISP_GETMARK(lispgc_atommarks, ai) == FALSE)
	return;
    LISP_UNMARK(lispgc_atommarks, ai);

    switch (atom->type) {
        case ATOM_FUNCTION:
        case ATOM_MACRO:
	    lispgc_trace_object ((lispptr) atom->detail);
	    break;

        case ATOM_ARRAY:
	    lispgc_trace_array (a);
	    break;
    }
    lispgc_trace_object (atom->value);
    lispgc_trace_object (atom->fun);
    lispgc_trace_object (atom->binding);
}

void
lispgc_mark_non_internal ()
{
    /* Initialise mark map, */
    memset (lispgc_listmarks, -1, sizeof (lispgc_listmarks));
    memset (lispgc_atommarks, -1, sizeof (lispgc_atommarks));

    lispgc_trace_object (lispptr_universe);
    lispgc_trace_object (lispimage_initfun);
}

void
lispgc_mark (void)
{
    lispgc_mark_non_internal ();

    lispgc_trace_expr_toplevel (LISPCONTEXT_FUNSTACK());

    /* Mark temporarily untraceable objects. */
    lispgc_trace_object (lispgc_save_stack);
    lispgc_trace_object (lispgc_car);
    lispgc_trace_object (lispgc_cdr);
    lispgc_trace_object (lispgc_retval_current);

    /* Mark bookkeeping lists. */
    lispgc_trace_expr_toplevel (lisp_lists_free);
    lispgc_trace_expr_toplevel (lisp_atoms_free);
    lispgc_trace_expr_toplevel (lisp_numbers_free);

    lispgc_trace_atom (lisp_atom_evaluated_go);
    lispgc_trace_atom (lisp_atom_evaluated_return_from);
}
 
/* Remove all unmarked cons. */
void
lispgc_sweep (void)
{
    unsigned  i;
    unsigned  j;
    unsigned  idx;
    char  c;

    /* Free marked atoms.
     *
     * Atoms must be freed first, so they can remove their internal conses.
     */
    DOTIMES(i, sizeof (lispgc_atommarks)) {
	c = 1;
	DOTIMES(j, 8) {
	    if (lispgc_atommarks[i] & c) {
	        idx = (i << 3) + j;
		if (LISPPTR_TO_ATOM(idx)->type != ATOM_UNUSED)
	            lispatom_remove (TYPEINDEX_TO_LISPPTR(LISPATOM_TYPE(idx), idx));
            }

	    c <<= 1;
        }
    }

    /* Free marked list elements. */
    DOTIMES(i, sizeof (lispgc_listmarks)) {
        c = 1;
	DOTIMES(j, 8) {
	    if (lispgc_listmarks[i] & c) {
	        idx = (i << 3) + j;
	        lisplist_free (idx);
            }

	    c <<= 1;
        }
    }
}

void
lispgc_pass (void)
{
    lispgc_running = TRUE;
    lispgc_mark ();
    lispgc_sweep ();
    lispgc_running = FALSE;
}

void
lispgc_force ()
{
    if (lispgc_running)
	return;

#if LISP_VERBOSE_GC
    printf ("before gc");
    lispgc_print_stats ();
#endif

    lispgc_pass ();

#ifdef LISP_VERBOSE_GC
    printf (" after gc");
    lispgc_print_stats ();
#endif

}

void
lispgc_force_user ()
{
    if (lispgc_running)
	return;

    printf ("before gc");
    lispgc_print_stats ();

    lispgc_pass ();

    printf (" after gc");
    lispgc_print_stats ();
}

void
lispgc_print_stats ()
{
    unsigned c[ATOM_MAXTYPE + 1];
    unsigned i;
    unsigned atoms;

    for (i = 0; i <= ATOM_MAXTYPE; i++)
        c[i] = 0;

    for (atoms = i = 0; i < NUM_ATOMS; i++)
        if (lisp_atoms[i].type != ATOM_UNUSED) {
            atoms++;
            c[(unsigned) lisp_atoms[i].type]++;
        }

    printf (": %d cons, %d atoms "
            "(%d var, %d num, %d arr, %d str, "
            "%d fun, %d mac, %d usr, %d pkg, %d blt, %d spc).\n",
            lisplist_num_used,
            atoms,
            c[ATOM_VARIABLE], c[ATOM_NUMBER], c[ATOM_ARRAY], c[ATOM_STRING],
            c[ATOM_FUNCTION], c[ATOM_MACRO], c[ATOM_USERSPECIAL],
            c[ATOM_PACKAGE], c[ATOM_BUILTIN], c[ATOM_SPECIAL]);
    fflush (stdout);
}

void
lispgc_init ()
{
    lispgc_running = FALSE;
    lispgc_save_stack = lispptr_nil;
    lispgc_retval_current = lispptr_nil;
    lispgc_car = lispptr_nil;
    lispgc_cdr = lispptr_nil;
}
