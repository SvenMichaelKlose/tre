/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "error.h"
#include "gc.h"
#include "builtin_sequence.h"
#include "number.h"
#include "io.h"
#include "xxx.h"

#include <string.h>

treptr
trelist_last (treptr l)
{
    while (CDR(l) != treptr_nil)
		l = CDR(l);

    return l;
}

treptr
trelist_copy_tree (treptr l)
{
    treptr car;
    treptr cdr;
    treptr ret;

    if (TREPTR_IS_ATOM(l))
		return l;

    car = trelist_copy_tree (CAR(l));
    tregc_push (car);
    cdr = trelist_copy_tree (CDR(l));
    ret = CONS(car, cdr);
    tregc_pop ();

    return ret;
}

treptr
trelist_copy (treptr l)
{
    if (TREPTR_IS_ATOM(l))
		return l;

    return CONS(CAR(l), trelist_copy (CDR(l)));
}

treptr
trelist_delete (size_t i, treptr l)
{
    treptr  p;
    treptr  f = treptr_nil;

    if (i == 0)
		return CDR(l);

    for (p = l; p != treptr_nil; i--, p = CDR(p)) {
		if (i) {
	    	f = p;
	    	continue;
		}

		RPLACD(f, CDR(p));
		return l;
    }

    return treerror (l, "trelist_delete: index '%d' out of range", i);
}

long
trelist_position (treptr elt, treptr l)
{
    long c = 0;

    while (l != treptr_nil) {
		if (CAR(l) == elt)
	    	return c;

        l = CDR(l);
		c++;
    }

    return -1;
}


long
trelist_position_name (treptr elt, treptr l)
{
    long c = 0;
	const char * eltname = TREATOM_NAME(elt);

    while (l != treptr_nil) {
		if (TREPTR_IS_SYMBOL(CAR(l)) && ! strcmp (TREATOM_NAME(CAR(l)), eltname))
	    	return c;

        l = CDR(l);
		c++;
    }

    return -1;
}

size_t
trelist_length (treptr p)
{
    size_t len = 0;

    while (p != treptr_nil) {
		len++;
		p = CDR(p);
    }

    return len;
}

treptr
trelist_nthcdr (treptr l, size_t idx)
{
    while (l != treptr_nil) {
		if (TREPTR_IS_ATOM(l))
			treerror_norecover (l, "internal NTHCDR: cons expected");
		if (!idx--)
			break;
        l = CDR(l);
	}

	return l;
}

treptr
trelist_nth (treptr l, size_t idx)
{
	l = trelist_nthcdr (l, idx);

    if (l == treptr_nil)
		return l;
    return CAR(l);
}

void
trelist_t_set (treptr s, size_t idx, treptr val)
{
    RPLACA(trelist_nthcdr (s, idx), val);
}

treptr
trelist_t_get (treptr s, size_t idx)
{
    return trelist_nth (s, idx);
}

struct tre_sequence_type trelist_seqtype = {
	trelist_t_set,
	trelist_t_get,
	trelist_length
};

bool
trelist_check_type (treptr list, size_t type)
{
    for (; list != treptr_nil; list = CDR(list))
        if (TREPTR_TYPE(CAR(list)) != type)
	    	return FALSE;
    return TRUE;
}

void
trelist_append (treptr *lst, treptr lst2)
{
    treptr tmp;

    if (lst2 == treptr_nil)
		return;

    if (*lst == treptr_nil) {
        *lst = lst2;
		return;
    }

    tmp = trelist_last (*lst);
    RPLACD(tmp, lst2);
}

bool
trelist_equal (treptr la, treptr lb)
{
    while (la != treptr_nil && lb != treptr_nil) {
        if (TREPTR_IS_CONS(la) != TREPTR_IS_CONS(lb))
	    	return FALSE;

        if (TREPTR_IS_ATOM(la))
	    	return la == lb;

        if (trelist_equal (CAR(la), CAR(lb)) == FALSE)
	    	return FALSE;

		la = CDR(la);
		lb = CDR(lb);
    }

    return TRUE;
}
