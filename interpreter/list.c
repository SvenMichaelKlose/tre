/*
 * TRE interpreter
 * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 *
 * List related section.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "error.h"
#include "gc.h"
#include "builtin_sequence.h"
#include "number.h"
#include "io.h"
#include "diag.h"
#include "xxx.h"

#include <string.h>

treptr tre_lists_free;
struct tre_list tre_lists[NUM_LISTNODES];
ulong trelist_num_used;

#define TRENODE_SET(node, value) \
    (node)->car = car; 	\
    (node)->cdr = cdr;

#ifdef TRE_LIST_DIAGNOSTICS
treptr
trelist_car (treptr lst)
{
    CHKPTR(_CAR(lst));
    if (TRE_GETMARK(trediag_listmarks, lst))
        treerror_internal (_CAR(lst), "car of free cons");

    return _CAR(lst);
}

treptr
trelist_cdr (treptr lst)
{
    CHKPTR(_CDR(lst));
    if (TRE_GETMARK(trediag_listmarks, lst))
        treerror_internal (_CAR(lst), "cdr using free cons. cdr gone. car");

    return _CDR(lst);
}
#endif

void
trelist_rplaca (treptr cons, treptr val)
{
    CHKPTR(val);
#ifdef TRE_LIST_DIAGNOSTICS
    if (TRE_GETMARK(trediag_listmarks, cons))
		treerror_internal (cons, "rplaca of free cons");
#endif

    _CAR(cons) = val;
}

void
trelist_rplacd (treptr cons, treptr val)
{
    CHKPTR(val);
#ifdef TRE_LIST_DIAGNOSTICS
    if (TRE_GETMARK(trediag_listmarks, cons))
		treerror_internal (cons, "rplacd of free cons");
#endif

    _CDR(cons) = val;
}

/*
 * Free single list element.
 */
void
trelist_free (treptr node)
{
    CHKPTR(node);

#ifdef TRE_LIST_DIAGNOSTICS
    if (TREPTR_IS_ATOM(node))
		treerror_internal (node, "list_free: not a cons");

    if (TRE_GETMARK(trediag_listmarks, node))
        treerror_internal (treptr_nil, "already free cons");

    _CAR(node) = -5;
#endif

	TREDIAG_FREE_CONS(node);

    _CDR(node) = tre_lists_free;
    tre_lists_free = node;
#ifdef TRE_COUNT_LISTNODES
    trelist_num_used--;
#endif
}

/*
 * Free list including sublists.
 *
 * Atoms are left alone.
 */
void
trelist_free_expr (treptr node)
{
    if (TREPTR_IS_ATOM(node))
		return;

	trelist_free_expr (CAR(node));
	trelist_free_expr (CDR(node));
    trelist_free (node);
}

/*
 * Free pure list, ignoring sublists.
 */
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

/* Collect garbage and try again, */
void
trelist_gc ()
{
	tregc_force ();
   	if (tre_lists_free == treptr_nil)
    	treerror_internal (treptr_invalid, "no more free list elements");
}

/*
 * Allocate a list node.
 */
treptr
_trelist_get (treptr car, treptr cdr)
{
    treptr ret;

    CHKPTR(car);
    CHKPTR(cdr);
	tregc_car = car;
	tregc_car = cdr;

	if (tre_lists_free == treptr_nil)
		tregc_force ();
    ret = tre_lists_free;

    tre_lists_free = _CDR(ret);
    TRELIST_SET(ret, car, cdr);
    tregc_retval (ret);

#ifdef TRE_COUNT_LISTNODES
    trelist_num_used++;
#endif
#ifdef TRE_LIST_DIAGNOSTICS
    if (TRE_GETMARK(trediag_listmarks, ret) == FALSE)
        treerror_internal (ret, "trelist_get(): already allocd cons");
#endif
    TREDIAG_ALLOC_CONS(ret);
#ifdef TRE_GC_DEBUG
    if (tre_is_initialized)
        tregc_force ();
#endif

    return ret;
}

/*
 * UTILITIES
 *
 * These are implemented in C because lists are also used by the
 * interpreter to stack free lists, atoms and numbers.
 */

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
	treptr cdr;
	treptr ret;

    if (TREPTR_IS_ATOM(l))
		return l;

    cdr = trelist_copy (CDR(l));
	tregc_push (cdr);
    ret = CONS(CAR(l), cdr);
	tregc_pop ();
    return ret;
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
ulong
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

#ifdef TRE_LIST_DIAGNOSTICS
    if (TREPTR_IS_ATOM(lst2))
		treerror_internal (lst2, "trelist_append: can append list only");
#endif

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

void
trelist_init ()
{
    ulong  i;

    /* Make a list of all elements. */
    for (i = 0; i < LAST_LISTNODE; i++) {
#ifdef TRE_LIST_DIAGNOSTICS
		tre_lists[i].car = (treptr) -5;
#endif
		tre_lists[i].cdr = (treptr) i + 1;
    }
    tre_lists[LAST_LISTNODE].cdr = TREPTR_NIL();

    tre_lists_free = 0;
    trelist_num_used = 0;
}
