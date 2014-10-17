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
#include "symtab.h"
#include "assert.h"

treptr tre_lists_free;
struct tre_list tre_lists[NUM_LISTNODES];
treptr tre_listprops[NUM_LISTNODES];
treptr tre_default_listprop;
tre_size trelist_num_used;

treptr
car (treptr x)
{
    RETURN_NIL(x);
    ASSERT_CONS(x);
    return _CAR(x);
}

treptr
cdr (treptr x)
{
    RETURN_NIL(x);
    ASSERT_CONS(x);
    return _CDR(x);
}

treptr
cpr (treptr x)
{
    RETURN_NIL(x);
    ASSERT_CONS(x);
    return _CPR(x);
}

treptr
rplaca (treptr cons, treptr val)
{
    ASSERT_CONS(cons);
    _CAR(cons) = val;
    return cons;
}

treptr
rplacd (treptr cons, treptr val)
{
    ASSERT_CONS(cons);
    _CDR(cons) = val;
    return cons;
}

treptr
rplacp (treptr cons, treptr val)
{
    ASSERT_CONS(cons);
    _CPR(cons) = val;
    return cons;
}

void
cons_free (treptr x)
{
    _CDR(x) = tre_lists_free;
    tre_lists_free = x;
    trelist_num_used--;
}

void
cons_free_list (treptr x)
{
    treptr d;

    while (NOT_NIL(x)) {
        d = CDR(x);
        cons_free (x);
        x = d;
    }
}

void
cons_free_tree (treptr x)
{
    if (ATOMP(x))
		return;

	cons_free_tree (CAR(x));
	cons_free_tree (CDR(x));
    cons_free (x);
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
cons (treptr car, treptr cdr)
{
    treptr cons;

    if (!tre_lists_free)
	    trelist_gc (car, cdr);

    cons = tre_lists_free;
    tre_lists_free = _CDR(cons);

    _CAR(cons) = car;
    _CDR(cons) = cdr;
    _CPR(cons) = SYMBOL_VALUE(tre_default_listprop);

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
