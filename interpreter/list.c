/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <string.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "error.h"
#include "gc.h"
#include "builtin_sequence.h"
#include "number.h"
#include "stream.h"
#include "xxx.h"
#include "symtab.h"
#include "assert.h"

treptr
last (treptr x)
{
    if (NOT(x))
        return x;
    ASSERT_CONS(x);

    while (NOT_NIL(CDR(x)))
		x = CDR(x);

    return x;
}

treptr
list_copy_tree (treptr x)
{
    treptr a;
    treptr d;
    treptr ret;

    if (ATOMP(x))
		return x;

    a = list_copy_tree (CAR(x));
    tregc_push (a);
    d = list_copy_tree (CDR(x));
    ret = CONS(a, d);
    tregc_pop ();

    return ret;
}

treptr
list_copy (treptr x)
{
    if (ATOMP(x))
		return x;

    return CONS(CAR(x), list_copy (CDR(x)));
}

treptr
list_delete (tre_size i, treptr x)
{
    treptr  p;
    treptr  f = treptr_nil;

    if (i == 0)
		return CDR(x);

    for (p = x; NOT_NIL(p); i--, p = CDR(p)) {
		if (i) {
	    	f = p;
	    	continue;
		}

		RPLACD(f, CDR(p));
		return x;
    }

    return treerror (x, "list_delete: Index '%d' out of range.", i);
}

long
list_position (treptr elt, treptr x)
{
    long c = 0;

    while (NOT_NIL(x)) {
		if (CAR(x) == elt)
	    	return c;

        x = CDR(x);
		c++;
    }

    return -1;
}

tre_size
list_length (treptr p)
{
    tre_size len = 0;

    while (NOT_NIL(p)) {
		len++;
		p = CDR(p);
    }

    return len;
}

treptr
list_nthcdr (treptr x, tre_size idx)
{
    while (NOT_NIL(x)) {
#ifndef TRE_NO_ASSERTIONS
		if (ATOMP(x))
			treerror_norecover (x, "Internal NTHCDR: cons expected.");
#endif
		if (!idx--)
			break;
        x = CDR(x);
	}

	return x;
}

treptr
list_nth (treptr x, tre_size idx)
{
	x = list_nthcdr (x, idx);

    if (NOT(x))
		return x;
    return CAR(x);
}

void
list_t_set (treptr s, tre_size idx, treptr val)
{
    RPLACA(list_nthcdr (s, idx), val);
}

treptr
list_t_get (treptr s, tre_size idx)
{
    return list_nth (s, idx);
}

struct tre_sequence_type list_seqtype = {
	list_t_set,
	list_t_get,
	list_length
};

bool
list_check_type (treptr list, tre_size type)
{
    for (; NOT_NIL(list); list = CDR(list))
        if (TREPTR_TYPE(CAR(list)) != type)
	    	return FALSE;
    return TRUE;
}

bool
list_equal (treptr la, treptr lb)
{
    while (NOT_NIL(la) && NOT_NIL(lb)) {
        if (CONSP(la) != CONSP(lb))
	    	return FALSE;

        if (ATOMP(la))
	    	return la == lb;

        if (list_equal (CAR(la), CAR(lb)) == FALSE)
	    	return FALSE;

		la = CDR(la);
		lb = CDR(lb);
    }

    return TRUE;
}
