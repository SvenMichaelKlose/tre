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
#include "io.h"
#include "xxx.h"
#include "symbol.h"

treptr
trelist_last (treptr l)
{
    while (NOT_NIL(CDR(l)))
		l = CDR(l);

    return l;
}

treptr
trelist_copy_tree (treptr l)
{
    treptr car;
    treptr cdr;
    treptr ret;

    if (ATOMP(l))
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
    if (ATOMP(l))
		return l;

    return CONS(CAR(l), trelist_copy (CDR(l)));
}

treptr
trelist_delete (tre_size i, treptr l)
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

    return treerror (l, "trelist_delete: Index '%d' out of range.", i);
}

long
trelist_position (treptr elt, treptr l)
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


long
trelist_position_name (treptr elt, treptr l)
{
    long c = 0;
	const char * eltname = TRESYMBOL_NAME(elt);

    while (NOT_NIL(l)) {
		if (SYMBOLP(CAR(l)) && ! strcmp (TRESYMBOL_NAME(CAR(l)), eltname))
	    	return c;

        l = CDR(l);
		c++;
    }

    return -1;
}

tre_size
trelist_length (treptr p)
{
    tre_size len = 0;

    while (NOT_NIL(p)) {
		len++;
		p = CDR(p);
    }

    return len;
}

treptr
trelist_nthcdr (treptr l, tre_size idx)
{
    while (NOT_NIL(l)) {
		if (ATOMP(l))
			treerror_norecover (l, "Internal NTHCDR: cons expected.");
		if (!idx--)
			break;
        l = CDR(l);
	}

	return l;
}

treptr
trelist_nth (treptr l, tre_size idx)
{
	l = trelist_nthcdr (l, idx);

    if (NOT(l))
		return l;
    return CAR(l);
}

void
trelist_t_set (treptr s, tre_size idx, treptr val)
{
    RPLACA(trelist_nthcdr (s, idx), val);
}

treptr
trelist_t_get (treptr s, tre_size idx)
{
    return trelist_nth (s, idx);
}

struct tre_sequence_type trelist_seqtype = {
	trelist_t_set,
	trelist_t_get,
	trelist_length
};

bool
trelist_check_type (treptr list, tre_size type)
{
    for (; NOT_NIL(list); list = CDR(list))
        if (TREPTR_TYPE(CAR(list)) != type)
	    	return FALSE;
    return TRUE;
}

void
trelist_append (treptr *lst, treptr lst2)
{
    treptr tmp;

    if (NOT(lst2))
		return;

    if (NOT(*lst)) {
        *lst = lst2;
		return;
    }

    tmp = trelist_last (*lst);
    RPLACD(tmp, lst2);
}

bool
trelist_equal (treptr la, treptr lb)
{
    while (NOT_NIL(la) && NOT_NIL(lb)) {
        if (CONSP(la) != CONSP(lb))
	    	return FALSE;

        if (ATOMP(la))
	    	return la == lb;

        if (trelist_equal (CAR(la), CAR(lb)) == FALSE)
	    	return FALSE;

		la = CDR(la);
		lb = CDR(lb);
    }

    return TRUE;
}
