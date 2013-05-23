/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
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
size_t trelist_num_used;

void
trelist_rplaca (treptr cons, treptr val)
{
    _CAR(cons) = val;
}

void
trelist_rplacd (treptr cons, treptr val)
{
    _CDR(cons) = val;
}

void
trelist_rplacp (treptr cons, treptr val)
{
    _CPR(cons) = val;
}

void
trelist_free (treptr node)
{
    _CDR(node) = tre_lists_free;
    tre_lists_free = node;
#ifdef TRE_VERBOSE_GC
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
	if (tre_lists_free != treptr_nil)
        return;

	tregc_force ();
   	if (tre_lists_free == treptr_nil)
    	treerror_internal (treptr_invalid, "out of conses");
}

treptr
_trelist_get (treptr car, treptr cdr)
{
    treptr ret;

    tregc_push (car);
    tregc_push (cdr);

	trelist_gc ();

    ret = tre_lists_free;
    tre_lists_free = _CDR(ret);
    _CAR(ret) = car;
    _CDR(ret) = cdr;
    _CPR(ret) = TRESYMBOL_VALUE(tre_default_listprop);

#ifdef TRE_VERBOSE_GC
    trelist_num_used++;
#endif

    tregc_pop ();
    tregc_pop ();
    return ret;
}

void
trecons_init ()
{
    size_t  i;

    for (i = 0; i < LAST_LISTNODE; i++)
		_CDR(i) = (treptr) i + 1;
    _CDR(LAST_LISTNODE) = TREPTR_NIL();

    tre_lists_free = 0;
    tre_default_listprop = treptr_nil;
    trelist_num_used = 0;
}
