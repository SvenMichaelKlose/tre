/*
 * tré - Copyright (c) 2005-2011 Sven Klose <pixel@copei.de>
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
#include "string2.h"
#include "alloc.h"
#include "symbol.h"
#include "xxx.h"
#include "special.h"
#include "image.h"

#include "io.h"
#include "main.h"

#include <stdio.h>
#include <string.h>

/* List element marks. */
char tregc_listmarks[NUM_LISTNODES >> 3];
char tregc_atommarks[NUM_ATOMS >> 3];

#define _TREGC_ALLOC_ATOM(index)	TRE_UNMARK(tregc_atommarks, index)
#define _TREGC_ALLOC_CONS(index)	TRE_UNMARK(tregc_listmarks, index)
#define _TREGC_FREE_ATOM(index)	TRE_MARK(tregc_atommarks, index)
#define _TREGC_FREE_CONS(index)	TRE_MARK(tregc_listmarks, index)

treptr tregc_car;
treptr tregc_cdr;
treptr tregc_save;
treptr tregc_save_stack;
treptr tregc_retval_current;

bool tregc_running;

/* Put expression on stack of expressions that should not be removed by the
 * garbage collector. Atoms are ignored.
 */
void
tregc_push (treptr expr)
{
	CHKPTR(expr);
	tregc_save = expr;
    TRELIST_PUSH(tregc_save_stack, expr);
}

treptr
tregc_push_compiled (treptr expr)
{
	tregc_push (expr);
	return expr;
}

void
tregc_pop ()
{
#ifdef TRE_DIAGNOSTICS
    if (tregc_save_stack == treptr_nil)
		treerror_internal (treptr_invalid, "GC save stack underflow");
#endif

	CHKPTR(_CAR(tregc_save_stack));
    TRELIST_POP(tregc_save_stack);
}

/*
 * Save current return value during GC.
 */
void
tregc_retval (treptr retval)
{
	CHKPTR(tregc_retval_current);
	CHKPTR(retval);
    tregc_retval_current = retval;
}

void
tregc_trace_list (treptr expr)
{
    while (expr != treptr_nil) {
        _TREGC_ALLOC_CONS(expr);
		expr = _CDR(expr);
    }
}

void tregc_trace_atom (treptr);

void
tregc_trace_tree (treptr p)
{
    treptr i;

    _DOLIST(i, p) {
        /* Avoid circular trace. */
        if (TRE_GETMARK(tregc_listmarks, i) == FALSE)
	    	return;

        _TREGC_ALLOC_CONS(i);

        tregc_trace_object (_CAR(i));

        if (TREPTR_IS_ATOM(_CDR(i))) {
            tregc_trace_object (_CDR(i));
	    	return;
		}
    }
}

void
tregc_trace_object (treptr p)
{
    if (TREPTR_IS_CONS(p))
        tregc_trace_tree (p);
    else
        tregc_trace_atom (p);
}

void
tregc_trace_array (treptr arr)
{
    treptr    * i = TREATOM_DETAIL(arr);
    ulong  size = TREARRAY_SIZE(arr);

    /* Mark dimension list. */
    tregc_trace_tree (TREATOM_VALUE(arr));

    /* Mark elements in array. */
    while (size--)
		tregc_trace_object (*i++);
}

void
tregc_trace_atom (treptr a)
{
    ulong  ai = TREPTR_INDEX(a);

    /* Avoid circular trace. */
    if (TRE_GETMARK(tregc_atommarks, ai) == FALSE)
		return;
    _TREGC_ALLOC_ATOM(ai);

    switch (TREATOM_TYPE(a)) {
        case TRETYPE_FUNCTION:
        case TRETYPE_MACRO:
	    	tregc_trace_object ((treptr) (size_t) TREATOM_DETAIL(a));
	    	break;

        case TRETYPE_ARRAY:
	    	tregc_trace_array (a);
	    	break;

        case TRETYPE_UNUSED:
			return;
    }
    tregc_trace_object (TREATOM_VALUE(a));
    tregc_trace_object (TREATOM_FUN(a));
    tregc_trace_object (TREATOM_PACKAGE(a));
    tregc_trace_object (TREATOM_BINDING(a));
}

void
tregc_init_maps ()
{
    memset (tregc_listmarks, -1, sizeof (tregc_listmarks));
    memset (tregc_atommarks, -1, sizeof (tregc_atommarks));
}

void
tregc_mark_non_internal ()
{
    tregc_trace_object (treptr_universe);
    tregc_trace_object (treimage_initfun);
}

void
tregc_mark_stack (void)
{
	treptr * s;
	for (s = trestack_ptr; s != trestack_top; s++)
		tregc_trace_object (*s);
}

void
tregc_mark (void)
{
	tregc_init_maps ();
    tregc_mark_non_internal ();
    tregc_mark_stack ();

    tregc_trace_list (TRECONTEXT_FUNSTACK());

    tregc_trace_object (tregc_car);
    tregc_trace_object (tregc_cdr);

    tregc_trace_object (tregc_save);
    tregc_trace_object (tregc_save_stack);
    tregc_trace_object (tregc_retval_current);

    tregc_trace_list (tre_lists_free);

    tregc_trace_atom (tre_atom_evaluated_go);
    tregc_trace_atom (tre_atom_evaluated_return_from);
}
 
void
tregc_sweep (void)
{
    ulong  i;
    ulong  j;
    ulong  idx;
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
                if (TREPTR_TO_ATOM(idx).type != TRETYPE_UNUSED
					&& TREPTR_TO_ATOM(idx).compiled_fun == NULL)
	           	    treatom_remove (TREATOM_TO_PTR(idx));
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

/*
int gc_run = 0;
*/
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
	fflush (stdout);
#endif

}

void
tregc_force_user ()
{
    if (tregc_running)
		return;

    printf ("\nbefore gc");
    tregc_print_stats ();

    tregc_pass ();

    printf (" after gc");
    tregc_print_stats ();
}

void
tregc_print_stats ()
{
    ulong c[TRETYPE_MAXTYPE + 1];
    ulong i;
    ulong atoms;

    for (i = 0; i <= TRETYPE_MAXTYPE; i++)
        c[i] = 0;

    for (atoms = i = 0; i < NUM_ATOMS; i++)
        if (tre_atoms[i].type != TRETYPE_UNUSED) {
            atoms++;
            c[(ulong) tre_atoms[i].type]++;
        }

    printf (": %ld cons, %ld atoms. %ld syms, "
            "(%ld var, %ld num, %ld arr, %ld str, "
            "%ld fun, %ld mac, %ld usr, %ld pkg, %ld blt, %ld spc).\n",
            trelist_num_used, atoms, num_symbols,
            c[TRETYPE_VARIABLE], c[TRETYPE_NUMBER], c[TRETYPE_ARRAY], c[TRETYPE_STRING],
            c[TRETYPE_FUNCTION], c[TRETYPE_MACRO], c[TRETYPE_USERSPECIAL],
            c[TRETYPE_PACKAGE], c[TRETYPE_BUILTIN], c[TRETYPE_SPECIAL]);
    fflush (stdout);
}

void
tregc_init ()
{
    tregc_running = FALSE;
    tregc_save_stack = treptr_nil;
    tregc_save = treptr_nil;
    tregc_retval_current = treptr_nil;
    tregc_car = treptr_nil;
    tregc_cdr = treptr_nil;
}
