/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <string.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "error.h"
#include "gc.h"
#include "builtin_sequence.h"
#include "number.h"
#include "io.h"
#include "xxx.h"
#include "symbol.h"

treptr tre_lists_free;
struct tre_list tre_lists[NUM_LISTNODES];
treptr tre_listprops[NUM_LISTNODES];
treptr tre_default_listprop;
tre_size trelist_num_used;

void
trelist_assert (treptr x)
{
    if (!LISTP(x))
        treerror_norecover (x, "List expected.");
}

treptr
trelist_car (treptr x)
{
    trelist_assert (x);
    RETURN_NIL(x);
    return _CAR(x);
}

treptr
trelist_cdr (treptr x)
{
    trelist_assert (x);
    RETURN_NIL(x);
    return _CDR(x);
}

treptr
trelist_cpr (treptr x)
{
    trelist_assert (x);
    RETURN_NIL(x);
    return _CPR(x);
}

void
trelist_rplac_assert (treptr x)
{
    if (!TREPTR_IS_CONS(x))
        treerror_norecover (x, "Cons expected.");
}

treptr
trelist_rplaca (treptr cons, treptr val)
{
    trelist_rplac_assert (cons);
    _CAR(cons) = val;
    return cons;
}

treptr
trelist_rplacd (treptr cons, treptr val)
{
    trelist_rplac_assert (cons);
    _CDR(cons) = val;
    return cons;
}

treptr
trelist_rplacp (treptr cons, treptr val)
{
    trelist_rplac_assert (cons);
    _CPR(cons) = val;
    return cons;
}

void
trelist_free (treptr node)
{
    _CDR(node) = tre_lists_free;
    tre_lists_free = node;
    trelist_num_used--;
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

    while (NOT_NIL(node)) {
        cdr = CDR(node);
        trelist_free (node);
        node = cdr;
    }
}

void
trelist_gc (treptr car, treptr cdr)
{
    tregc_push (car);
    tregc_push (cdr);

	tregc_force ();
   	if (!tre_lists_free)
    	treerror_internal (treptr_invalid, "Out of conses.");

    tregc_pop ();
    tregc_pop ();
}

treptr
trelist_get (treptr car, treptr cdr)
{
    treptr cons;

    if (!tre_lists_free)
	    trelist_gc (car, cdr);

    cons = tre_lists_free;
    tre_lists_free = _CDR(cons);

    _CAR(cons) = car;
    _CDR(cons) = cdr;
    _CPR(cons) = TRESYMBOL_VALUE(tre_default_listprop);

    trelist_num_used++;

    return cons;
}

void
trecons_init ()
{
    treptr i;

    for (i = FIRST_LISTNODE; i < LAST_LISTNODE; i++)
		_CDR(i) = (treptr) i + 1;
    _CDR(LAST_LISTNODE) = 0;

    tre_lists_free = FIRST_LISTNODE;
    tre_default_listprop = treptr_nil;
    trelist_num_used = 0;
}
