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

treptr
last (treptr l)
{
    while (NOT_NIL(CDR(l)))
		l = CDR(l);

    return l;
}

treptr
list_copy_tree (treptr l)
{
    treptr a;
    treptr d;
    treptr ret;

    if (ATOMP(l))
		return l;

    a = list_copy_tree (CAR(l));
    tregc_push (a);
    d = list_copy_tree (CDR(l));
    ret = CONS(a, d);
    tregc_pop ();

    return ret;
}

treptr
list_copy (treptr l)
{
    if (ATOMP(l))
		return l;

    return CONS(CAR(l), list_copy (CDR(l)));
}

treptr
list_delete (tre_size i, treptr l)
{
    treptr  p;
    treptr  f = treptr_nil;

    if (i == 0)
		return CDR(l);

    for (p = l; NOT_NIL(p); i--, p = CDR(p)) {
		if (i) {
	    	f = p;
	    	continue;
		}

		RPLACD(f, CDR(p));
		return l;
    }

    return treerror (l, "list_delete: Index '%d' out of range.", i);
}

long
list_position (treptr elt, treptr l)
{
    long c = 0;

    while (NOT_NIL(l)) {
		if (CAR(l) == elt)
	    	return c;

        l = CDR(l);
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
list_nthcdr (treptr l, tre_size idx)
{
    while (NOT_NIL(l)) {
#ifndef TRE_NO_ASSERTIONS
		if (ATOMP(l))
			treerror_norecover (l, "Internal NTHCDR: cons expected.");
#endif
		if (!idx--)
			break;
        l = CDR(l);
	}

	return l;
}

treptr
list_nth (treptr l, tre_size idx)
{
	l = list_nthcdr (l, idx);

    if (NOT(l))
		return l;
    return CAR(l);
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
