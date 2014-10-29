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
#include "queue.h"
#include "funcall.h"

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
    treptr q;
    treptr i;

    ASSERT_LIST(x);

    q = tre_make_queue ();
    tregc_push (q);
    DOLIST(i, x)
        tre_enqueue (q, CAR(i));
    tregc_pop ();

    return tre_queue_list (q);
}

treptr
list_delete (tre_size i, treptr x)
{
    treptr  p;
    treptr  f = NIL;

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
nthcdr (tre_size idx, treptr x)
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
trelist_nthcdr (treptr idx, treptr x)
{
    ASSERT_NUMBER(idx);

    return nthcdr ((tre_size) TRENUMBER_VAL(idx), x);
}

treptr
nth (tre_size idx, treptr x)
{
	x = nthcdr (idx, x);

    if (NOT(x))
		return x;
    return CAR(x);
}

treptr
trelist_nth (treptr idx, treptr x)
{
    ASSERT_NUMBER(idx);

    return nth ((tre_size) TRENUMBER_VAL(idx), x);
}

void
list_t_set (treptr s, tre_size idx, treptr val)
{
    RPLACA(nthcdr (idx, s), val);
}

treptr
list_t_get (treptr s, tre_size idx)
{
    return nth (idx, s);
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

treptr
filter (treptr fun, treptr x)
{
    treptr  q = tre_make_queue ();
    treptr  i;

    ASSERT_LIST(x);
    tregc_push (q);
    DOLIST(i, x)
        tre_enqueue (q, funcall (fun, CONS(CAR(i), NIL)));
    tregc_pop ();

    return tre_queue_list (q);
}

treptr
cdrlist (treptr x)
{
    treptr  q = tre_make_queue ();
    treptr  i;

    tregc_push (q);
    DOLIST(i, x)
        tre_enqueue (q, CDAR(i));
    tregc_pop ();

    return tre_queue_list (q);
}

treptr
mapcar_carlist (treptr x)
{
    treptr  q = tre_make_queue ();
    treptr  i;

    tregc_push (q);
    DOLIST(i, x) {
        if (NOT(CAR(i)))
            goto skip_rest;
        ASSERT_CONS(CAR(i));
        tre_enqueue (q, CAAR(i));
    }
    tregc_pop ();

    return tre_queue_list (q);

skip_rest:
    tregc_pop ();
    return NIL;
}

treptr
mapcar (treptr fun, treptr x)
{
    treptr  q = tre_make_queue ();
    treptr  args;

    ASSERT_LIST(x);
    tregc_push (q);
    while (1) {
        tregc_push (x);
        args = mapcar_carlist (x);
        tregc_push (args);
        if (NOT(args))
            break;
        tre_enqueue (q, funcall (fun, args));
        x = cdrlist (x);
        tregc_pop ();
        tregc_pop ();
    }
    tregc_pop ();
    tregc_pop ();
    tregc_pop ();

    return tre_queue_list (q);
}
