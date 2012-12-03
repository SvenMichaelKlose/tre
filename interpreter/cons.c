/*
 * tré – Copyright (c) 2005–2009,2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "error.h"
#include "gc.h"
#include "builtin_sequence.h"
#include "number.h"
#include "io.h"
#include "diag.h"
#include "xxx.h"

#include <string.h>

treptr tre_lists_free;
struct tre_list tre_lists[NUM_LISTNODES];
treptr tre_listprops[NUM_LISTNODES];
treptr tre_default_listprop;
size_t trelist_num_used;

#ifdef TRE_LIST_DIAGNOSTICS
treptr
trelist_car (treptr lst)
{
    CHKPTR(_CAR(lst));
    if (TRE_GETMARK(trediag_listmarks, lst))
        treerror_internal (treptr_nil, "free CAR");

    return _CAR(lst);
}

treptr
trelist_cdr (treptr lst)
{
    CHKPTR(_CDR(lst));
    if (TRE_GETMARK(trediag_listmarks, lst))
        treerror_internal (treptr_nil, "free CDR");

    return _CDR(lst);
}

treptr
trelist_cpr (treptr lst)
{
    CHKPTR(_CPR(lst));
    if (TRE_GETMARK(trediag_listmarks, lst))
        treerror_internal (treptr_nil, "free CPR");

    return _CPR(lst);
}
#endif

void
trelist_rplaca (treptr cons, treptr val)
{
    CHKPTR(val);
#ifdef TRE_LIST_DIAGNOSTICS
    if (TRE_GETMARK(trediag_listmarks, cons))
		treerror_internal (cons, "RPLACA on free cons");
#endif

    _CAR(cons) = val;
}

void
trelist_rplacd (treptr cons, treptr val)
{
    CHKPTR(val);
#ifdef TRE_LIST_DIAGNOSTICS
    if (TRE_GETMARK(trediag_listmarks, cons))
		treerror_internal (cons, "RPLACD on free cons");
#endif

    _CDR(cons) = val;
}

void
trelist_rplacp (treptr cons, treptr val)
{
    CHKPTR(val);
#ifdef TRE_LIST_DIAGNOSTICS
    if (TRE_GETMARK(trediag_listmarks, cons))
		treerror_internal (cons, "RPLACP on free cons");
#endif

    _CPR(cons) = val;
}


/*
 * Free single list element.
 */
void
trelist_free (treptr node)
{
    CHKPTR(node);

#ifdef TRE_LIST_DIAGNOSTICS
    if (TREPTR_IS_ATOM(node))
		treerror_internal (node, "list_free: not a cons");

    if (TRE_GETMARK(trediag_listmarks, node))
        treerror_internal (treptr_nil, "already free cons");

    _CAR(node) = -5;
#endif

	TREDIAG_FREE_CONS(node);

    _CDR(node) = tre_lists_free;
    tre_lists_free = node;
#ifdef TRE_COUNT_LISTNODES
    trelist_num_used--;
#endif
}

void
trelist_free_expr (treptr node)
{
    if (TREPTR_IS_ATOM(node))
		return;

	trelist_free_expr (CAR(node));
	trelist_free_expr (CDR(node));
    trelist_free (node);
}

void
trelist_free_toplevel (treptr node)
{
    treptr cdr;

    while (node != treptr_nil) {
        cdr = CDR(node);
        trelist_free (node);
        node = cdr;
    }
}

void
trelist_gc ()
{
	tregc_force ();
   	if (tre_lists_free == treptr_nil)
    	treerror_internal (treptr_invalid, "no more free list elements");
}

treptr
_trelist_get (treptr car, treptr cdr)
{
    treptr ret;

    CHKPTR(car);
    CHKPTR(cdr);
	tregc_car = car;
	tregc_car = cdr;

	if (tre_lists_free == treptr_nil)
		tregc_force ();
    ret = tre_lists_free;

    tre_lists_free = _CDR(ret);
    _CAR(ret) = car;
    _CDR(ret) = cdr;
    _CPR(ret) = TREATOM_VALUE(tre_default_listprop);
    tregc_retval (ret);

#ifdef TRE_COUNT_LISTNODES
    trelist_num_used++;
#endif
#ifdef TRE_LIST_DIAGNOSTICS
    if (TRE_GETMARK(trediag_listmarks, ret) == FALSE)
        treerror_internal (ret, "trelist_get(): already allocd cons");
#endif
    TREDIAG_ALLOC_CONS(ret);
#ifdef TRE_GC_DEBUG
    if (tre_is_initialized)
        tregc_force ();
#endif

    return ret;
}

void
trecons_init ()
{
    ulong  i;

    /* Make a list of all elements. */
    for (i = 0; i < LAST_LISTNODE; i++) {
#ifdef TRE_LIST_DIAGNOSTICS
		tre_lists[i].car = (treptr) -5;
#endif
		tre_lists[i].cdr = (treptr) i + 1;
    }
    tre_lists[LAST_LISTNODE].cdr = TREPTR_NIL();

    tre_lists_free = 0;
    trelist_num_used = 0;
    tre_default_listprop = treptr_nil;
}
