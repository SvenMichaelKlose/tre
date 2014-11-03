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
#include "stream.h"
#include "xxx.h"
#include "symtab.h"
#include "assert.h"

treptr conses_free;
struct tre_list conses[NUM_LISTNODES];
treptr conses_props[NUM_LISTNODES];
treptr tre_default_listprop;
tre_size conses_used;

void
check_cell_index (treptr x)
{
    if (TREPTR_INDEX(x) >= NUM_LISTNODES)
        treerror_internal (treptr_invalid, "Cell index out of range.");
}

#ifdef DEVELOPMENT
#define CHECK_CELL_INDEX(x) check_cell_index (x)
#else
#define CHECK_CELL_INDEX(x)
#endif

treptr
car (treptr x)
{
    RETURN_NIL(x);

    ASSERT_CONS(x);
    CHECK_CELL_INDEX(x);

    return _CAR(x);
}

treptr
cdr (treptr x)
{
    RETURN_NIL(x);

    ASSERT_CONS(x);
    CHECK_CELL_INDEX(x);

    return _CDR(x);
}

treptr
cpr (treptr x)
{
    RETURN_NIL(x);

    ASSERT_CONS(x);
    CHECK_CELL_INDEX(x);

    return _CPR(x);
}

treptr
rplaca (treptr cons, treptr val)
{
    ASSERT_CONS(cons);
    CHECK_CELL_INDEX(cons);
    _CAR(cons) = val;
    return cons;
}

treptr
rplacd (treptr cons, treptr val)
{
    ASSERT_CONS(cons);
    CHECK_CELL_INDEX(cons);
    _CDR(cons) = val;
    return cons;
}

treptr
rplacp (treptr cons, treptr val)
{
    ASSERT_CONS(cons);
    CHECK_CELL_INDEX(cons);
    _CPR(cons) = val;
    return cons;
}

void
cons_free (treptr x)
{
    CHECK_CELL_INDEX(x);
    _CDR(x) = conses_free;
    conses_free = x;
    conses_used--;
}

void
cons_free_list (treptr x)
{
    treptr d;

    while (NOT_NIL(x)) {
        d = _CDR(x);
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
list_gc (treptr car, treptr cdr)
{
    tregc_push (car);
    tregc_push (cdr);

	tregc_force ();
   	if (!conses_free)
    	treerror_internal (treptr_invalid, "Out of conses.");

    tregc_pop ();
    tregc_pop ();
}

treptr
cons (treptr car, treptr cdr)
{
    treptr cons;

    if (!conses_free)
	    list_gc (car, cdr);

    cons = conses_free;
    conses_free = _CDR(cons);

    _CAR(cons) = car;
    _CDR(cons) = cdr;
    _CPR(cons) = SYMBOL_VALUE(tre_default_listprop);

    conses_used++;

    return cons;
}

void
trecons_init ()
{
    treptr i;

    for (i = FIRST_LISTNODE; i < LAST_LISTNODE; i++)
		_CDR(i) = (treptr) i + 1;
    _CDR(LAST_LISTNODE) = 0;

    conses_free = FIRST_LISTNODE;
    tre_default_listprop = NIL;
    conses_used = 0;
}
