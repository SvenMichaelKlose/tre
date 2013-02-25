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

/* Return last cons of a list. */
treptr
trelist_last (treptr l)
{
    while (CDR(l) != treptr_nil)
		l = CDR(l);

    return l;
}

/* Copy tree. */
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

/*
 * Remove element from list.
 *
 * The element is unlinked and left for garbage collection.
 */
treptr
trelist_delete (ulong i, treptr l)
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

/* Get zero-indexed position of element in list. */
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


/* Get zero-indexed position of element in list by symbol name. */
long
trelist_position_name (treptr elt, treptr l)
{
    long c = 0;
	const char * eltname = TREATOM_NAME(elt);

    while (l != treptr_nil) {
		if (TREPTR_IS_VARIABLE(CAR(l)) && ! strcmp (TREATOM_NAME(CAR(l)), eltname))
	    	return c;

        l = CDR(l);
		c++;
    }

    return -1;
}

/* Get length of a pure list. */
size_t
trelist_length (treptr p)
{
    ulong len = 0;

    while (p != treptr_nil) {
		len++;
		p = CDR(p);
    }

    return len;
}

/* Return nth cons. */
treptr
trelist_nthcdr (treptr l, ulong idx)
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

/* Return nth element. */
treptr
trelist_nth (treptr l, ulong idx)
{
	l = trelist_nthcdr (l, idx);

    if (l == treptr_nil)
		return l;
    return CAR(l);
}

/* Sequence type: replace element at index. */
void
trelist_t_set (treptr s, ulong idx, treptr val)
{
    RPLACA(trelist_nthcdr (s, idx), val);
}

/* Sequence type: return element at index. */
treptr
trelist_t_get (treptr s, ulong idx)
{
    return trelist_nth (s, idx);
}

/* Sequence type configuration. */
struct tre_sequence_type trelist_seqtype = {
	trelist_t_set,
	trelist_t_get,
	trelist_length
};

/* Return T if all elements in a list are of the same type. */
bool
trelist_check_type (treptr list, ulong type)
{
    for (; list != treptr_nil; list = CDR(list))
        if (TREPTR_TYPE(CAR(list)) != type)
	    	return FALSE;
    return TRUE;
}

/* Append lst2 after lst. */
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

/* Return T if trees have the same layout and contain the same elements. */
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
