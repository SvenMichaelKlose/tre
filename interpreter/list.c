/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * List related section.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "error.h"
#include "gc.h"
#include "sequence.h"
#include "number.h"
#include "io.h"
#include "main.h"
#include "diag.h"
#include "xxx.h"

#include <string.h>
#include <strings.h>

struct tre_list tre_lists[NUM_LISTNODES_TOTAL];
#ifdef TRE_DIAGNOSTICS
char trelist_marks[NUM_LISTNODES_TOTAL >> 3];
#endif

treptr tre_lists_free;
unsigned trelist_num_used;

#define TRENODE_SET(node, value) \
    (node)->car = car; 	\
    (node)->cdr = cdr;

#ifdef TRE_DIAGNOSTICS
treptr
trelist_car (treptr lst)
{
    if (TRE_GETMARK(trelist_marks, lst) == FALSE)
        treerror_internal (_CAR(lst), "car of free cons");

    CHKPTR(_CAR(lst));
    return _CAR(lst);
}

treptr
trelist_cdr (treptr lst)
{
    if (TRE_GETMARK(trelist_marks, lst) == FALSE)
        treerror_internal (_CAR(lst), "cdr using free cons. cdr gone. car");

    CHKPTR(_CDR(lst));
    return _CDR(lst);
}
#endif

void
trelist_rplaca (treptr cons, treptr val)
{
#ifdef TRE_DIAGNOSTICS
    if (TRE_GETMARK(trelist_marks, cons) == FALSE)
	treerror_internal (cons, "rplaca of free cons");
#endif

    CHKPTR(val);
    _CAR(cons) = val;
}

void
trelist_rplacd (treptr cons, treptr val)
{
#ifdef TRE_DIAGNOSTICS
    if (TRE_GETMARK(trelist_marks, cons) == FALSE)
	treerror_internal (cons, "rplacd of free cons");
#endif

    CHKPTR(val);
    _CDR(cons) = val;
}

/*
 * Free single list element.
 */
void
trelist_free (treptr node)
{
    CHKPTR(node);

#ifdef TRE_DIAGNOSTICS
    if (TREPTR_IS_ATOM(node))
		treerror_internal (node, "list_free: not a cons");

    if (TRE_GETMARK(trelist_marks, node) == FALSE)
        treerror_internal (treptr_nil, "already free cons");

    TRE_UNMARK(trelist_marks, node);
    _CAR(node) = -5;
#endif

    _CDR(node) = tre_lists_free;
    tre_lists_free = node;
    trelist_num_used--;
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

/*
 * Allocate a list node.
 */
treptr
_trelist_get (treptr car, treptr cdr)
{
    treptr ret;

    CHKPTR(car);
    CHKPTR(cdr);

    ret = tre_lists_free;

#ifdef TRE_DIAGNOSTICS
    if (TRE_GETMARK(trelist_marks, ret))
        treerror_internal (ret, "already allocd cons");
    TRE_MARK(trelist_marks, ret);
#endif

    tre_lists_free = _CDR(ret);
    TRELIST_SET(ret, car, cdr);
    trelist_num_used++;
    tregc_retval (ret);

    /* Pop node from free list. */
    if (trelist_num_used > (NUM_LISTNODES - 16)) {
		/* Collect garbage and try again, */
		tregc_force ();
        if (tre_lists_free == treptr_nil)
	    	treerror_internal (treptr_invalid, "no more free list elements");
    }

#ifdef TRE_GC_DEBUG
    if (tre_is_initialized)
        tregc_force ();
#endif

    return ret;
}

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

/*
 * Copy tree.
 *
 * Will run garbage collection when out of list elements. The argument is
 * saved. Use tregc_save_push() for other unbound lists.
 */
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
trelist_delete (unsigned i, treptr l)
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
int
trelist_position (treptr elt, treptr l)
{
    int c = 0;

    while (l != treptr_nil) {
		if (CAR(l) == elt)
	    	return c;

        l = CDR(l);
		c++;
    }

    return -1;
}

/* Get length of a pure list. */
unsigned
trelist_length (treptr p)
{
    unsigned len = 0;

    while (p != treptr_nil) {
		len++;
		p = CDR(p);
    }

    return len;
}

/* Return cons pointing to the nth element. */
treptr
trelist_nth (treptr l, unsigned idx)
{
    while (l != treptr_nil && idx--)
        l = CDR(l);

    if (l == treptr_nil)
		return l;

    return CAR(l);
}

/* Sequence type: replace element at index. */
void
trelist_t_set (treptr s, unsigned idx, treptr val)
{
    s = trelist_nth (s, idx);

    RPLACA(s, val);
}

/* Sequence type: return element at index. */
treptr
trelist_t_get (treptr s, unsigned idx)
{
    s = trelist_nth (s, idx);

    return s;
}

/* Sequence type configuration. */
struct tre_sequence_type trelist_seqtype = {
	trelist_t_set,
	trelist_t_get,
	trelist_length
};

/* Return T if all elements in a list are of the same type. */
bool
trelist_check_type (treptr list, unsigned type)
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

#ifdef TRE_DIAGNOSTICS
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
    unsigned  i;

    /* Make a list of all elements. */
    for (i = 0; i < LAST_LISTNODE; i++) {
#ifdef TRE_DIAGNOSTICS
		tre_lists[i].car = (treptr) -23;
#endif
		tre_lists[i].cdr = (treptr) i + 1;
    }
    tre_lists[LAST_LISTNODE].cdr = TREPTR_NIL();

    tre_lists_free = 0;
    trelist_num_used = 0;

#ifdef TRE_DIAGNOSTICS
    bzero (trelist_marks, sizeof (trelist_marks));
#endif
}
