/*
 * tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>
#include <string.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "gc.h"
#include "eval.h"
#include "error.h"
#include "thread.h"
#include "util.h"
#include "array.h"
#include "string2.h"
#include "alloc.h"
#include "symbol.h"
#include "xxx.h"
#include "special.h"
#include "image.h"
#include "function.h"

#include "io.h"
#include "main.h"

char tregc_listmarks[NUM_LISTNODES >> 3];
char tregc_atommarks[NUM_ATOMS >> 3];

#define _TREGC_ALLOC_ATOM(index)	TRE_UNMARK(tregc_atommarks, index)
#define _TREGC_ALLOC_CONS(index)	TRE_UNMARK(tregc_listmarks, index)
#define _TREGC_FREE_ATOM(index)     TRE_MARK(tregc_atommarks, index)
#define _TREGC_FREE_CONS(index)     TRE_MARK(tregc_listmarks, index)

treptr tregc_unremovables;

bool tregc_running;

void
tregc_push (treptr expr)
{
    *--trestack_ptr = expr;
}

treptr
tregc_add_unremovable (treptr expr)
{
    tregc_unremovables = CONS(expr, tregc_unremovables);
	return expr;
}

void
tregc_pop ()
{
    trestack_ptr++;
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
        if (TRE_GETMARK(tregc_listmarks, i) == FALSE)
	    	return;

        _TREGC_ALLOC_CONS(i);

        tregc_trace_object (_CAR(i));
        tregc_trace_object (_CPR(i));

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
    tre_size    size = TREARRAY_SIZE(arr);
    treptr *  i = TREARRAY_VALUES(arr);
    tre_size    counter = size;

    tregc_trace_tree (TREARRAY_SIZES(arr));

    while (counter--)
		tregc_trace_object (*i++);
}

void
tregc_trace_atom (treptr a)
{
    tre_size  ai = TREPTR_INDEX(a);

    if (TRE_GETMARK(tregc_atommarks, ai) == FALSE)
		return;
    _TREGC_ALLOC_ATOM(ai);

    switch (TREATOM_TYPE(a)) {
        case TRETYPE_SYMBOL:
            tregc_trace_object (TRESYMBOL_VALUE(a));
            tregc_trace_object (TRESYMBOL_FUN(a));
            tregc_trace_object (TRESYMBOL_PACKAGE(a));
	    	break;

        case TRETYPE_FUNCTION:
        case TRETYPE_MACRO:
        case TRETYPE_USERSPECIAL:
            tregc_trace_object (TREFUNCTION_SOURCE(a));
            tregc_trace_object (TREFUNCTION_BYTECODE(a));
	    	break;

        case TRETYPE_ARRAY:
	    	tregc_trace_array (a);
	    	break;
    }
}

void
tregc_init_maps ()
{
    memset (tregc_listmarks, -1, sizeof (tregc_listmarks));
    memset (tregc_atommarks, -1, sizeof (tregc_atommarks));
}

void
tregc_mark_stack (void)
{
	treptr * s;
	for (s = trestack_ptr; s != trestack_top; s++)
		tregc_trace_object (*s);
}

void
tregc_mark (bool do_mark_only)
{
	tregc_init_maps ();

    tregc_trace_object (treptr_universe);
    tregc_trace_object (treimage_initfun);
    tregc_trace_tree (tregc_unremovables);

    tregc_trace_atom (tre_atom_evaluated_go);
    tregc_trace_atom (tre_atom_evaluated_return_from);

    if (do_mark_only)
        return;

    tregc_mark_stack ();
    tregc_trace_list (TRECONTEXT_FUNSTACK());
    tregc_trace_list (tre_lists_free);
}
 
void
tregc_sweep (void)
{
    tre_size i;
    tre_size j;
    tre_size idx;
    char   c;

    idx = 0;
    DOTIMES(i, sizeof (tregc_atommarks)) {
		c = 1;
		DOTIMES(j, 8) {
	    	if (tregc_atommarks[i] & c)
                if (tre_atom_types[idx] != TRETYPE_UNUSED)
	           	    treatom_remove (TREATOM_TO_PTR(idx));

	    	c <<= 1;
            idx++;
        }
    }

    idx = 0;
    DOTIMES(i, sizeof (tregc_listmarks)) {
        c = 1;
		DOTIMES(j, 8) {
	    	if (tregc_listmarks[i] & c)
	        	trelist_free (idx);

	    	c <<= 1;
            idx++;
        }
    }
}

void
tregc_pass (bool do_mark_only)
{
    tregc_running = TRUE;
    tregc_mark (do_mark_only);
    if (!do_mark_only)
        tregc_sweep ();
    tregc_running = FALSE;
}

void
tregc_force ()
{
    if (tregc_running)
		return;

#ifdef TRE_VERBOSE_GC
    printf ("before gc");
    tregc_print_stats ();
#endif

    tregc_pass (FALSE);

#ifdef TRE_VERBOSE_GC
    printf (" after gc");
    tregc_print_stats ();
	fflush (stdout);
#endif
}

void
tregc_mark_only ()
{
    tregc_pass (TRUE);
}

void
tregc_print_stats ()
{
    long c[TRETYPE_MAXTYPE + 1];
    long i;
    long atoms;

    for (i = 0; i <= TRETYPE_MAXTYPE; i++)
        c[i] = 0;

    for (atoms = i = 0; i < NUM_ATOMS; i++)
        if (tre_atom_types[i] != TRETYPE_UNUSED) {
            atoms++;
            c[(int) tre_atom_types[i]]++;
        }

    printf (": %ld cons, %ld atoms. %ld syms, "
            "(%ld var, %ld num, %ld arr, %ld str, "
            "%ld fun, %ld mac, %ld usr, %ld blt, %ld spc).\n",
            (long) trelist_num_used, atoms, (long) num_symbols,
            c[TRETYPE_SYMBOL], c[TRETYPE_NUMBER], c[TRETYPE_ARRAY], c[TRETYPE_STRING],
            c[TRETYPE_FUNCTION], c[TRETYPE_MACRO], c[TRETYPE_USERSPECIAL],
            c[TRETYPE_BUILTIN], c[TRETYPE_SPECIAL]);
    fflush (stdout);
}

void
tregc_init ()
{
    tregc_running = FALSE;
    tregc_unremovables = treptr_nil;
}
