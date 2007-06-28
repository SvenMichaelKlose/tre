/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * List related section.
 */

#include "lisp.h"
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

struct lisp_list lisp_lists[NUM_LISTNODES_TOTAL];
#ifdef LISP_DIAGNOSTICS
char lisplist_marks[NUM_LISTNODES_TOTAL >> 3];
#endif

lispptr lisplist_free_nodes;
unsigned lisplist_num_used;

#define LISPNODE_SET(node, value) \
    (node)->car = car; 	\
    (node)->cdr = cdr;

#ifdef LISP_DIAGNOSTICS
lispptr
lisplist_car (lispptr lst)
{
    if (LISP_GETMARK(lisplist_marks, lst) == FALSE)
        lisperror_internal (_CAR(lst), "car of free cons");

    CHKPTR(_CAR(lst));
    return _CAR(lst);
}

lispptr
lisplist_cdr (lispptr lst)
{
    if (LISP_GETMARK(lisplist_marks, lst) == FALSE)
        lisperror_internal (_CAR(lst), "cdr using free cons. cdr gone. car");

    CHKPTR(_CDR(lst));
    return _CDR(lst);
}
#endif

void
lisplist_rplaca (lispptr cons, lispptr val)
{
#ifdef LISP_DIAGNOSTICS
    if (LISP_GETMARK(lisplist_marks, cons) == FALSE)
	lisperror_internal (cons, "rplaca of free cons");
#endif

    CHKPTR(val);
    lispatom_ref (val);
    lispatom_unref (_CAR(cons));
    _CAR(cons) = val;
}

void
lisplist_rplacd (lispptr cons, lispptr val)
{
#ifdef LISP_DIAGNOSTICS
    if (LISP_GETMARK(lisplist_marks, cons) == FALSE)
	lisperror_internal (cons, "rplacd of free cons");
#endif

    CHKPTR(val);
    lispatom_ref (val);
    lispatom_unref (_CDR(cons));
    _CDR(cons) = val;
}

/*
 * Free single list element.
 */
void
lisplist_free_noref (lispptr node)
{
    CHKPTR(node);

#ifdef LISP_DIAGNOSTICS
    if (LISPPTR_IS_EXPR(node) == FALSE)
	lisperror_internal (node, "list_free: not a cons");

    if (LISP_GETMARK(lisplist_marks, node) == FALSE)
        lisperror_internal (lispptr_nil, "already free cons");
#endif

#ifdef LISP_DIAGNOSTICS
    LISP_UNMARK(lisplist_marks, node);
    _CAR(node) = -5;
#endif

    _CDR(node) = lisplist_free_nodes;

    lisplist_free_nodes = node;

    lisplist_num_used--;
}

/*
 * Free single list element.
 */
void
lisplist_free (lispptr node)
{
    lispatom_unref (CAR(node));
    lispatom_unref (CDR(node));
    lisplist_free_noref (node);
}

/*
 * Free list including sublists.
 *
 * Atoms are left alone.
 */
void
lisplist_free_expr (lispptr node)
{
    lispptr  car = CAR(node);
    lispptr  cdr = CDR(node);

    if (LISPPTR_IS_EXPR(car))
	lisplist_free_expr (car);
    if (LISPPTR_IS_EXPR(cdr))
	lisplist_free_expr (cdr);

    lisplist_free (node);
}

/*
 * Free pure list, excluding sublists.
 */
void
lisplist_free_toplevel (lispptr node)
{
    lispptr cdr;

    while (node != lispptr_nil) {
        cdr = CDR(node);
        lisplist_free (node);
        node = cdr;
    }
}

/*
 * Create a list node.
 *
 * Garbage collection is run when out of list elements.
 * The car and cdr is saved accordingly. Other lists not bound to an atom
 * must be saved in advanced using lispgc_save_push().
 */
lispptr
lisplist_get_noref (lispptr car, lispptr cdr)
{
    lispptr i;

    i = lisplist_free_nodes;

#ifdef LISP_DIAGNOSTICS
    if (LISP_GETMARK(lisplist_marks, i))
        lisperror_internal (i, "already allocd cons");
    LISP_MARK(lisplist_marks, i);
#endif

    lisplist_free_nodes = _CDR(i);
    LISPLIST_SET(i, car, cdr);
    lisplist_num_used++;

    return i;
}

/*
 * Create a list node.
 *
 * Garbage collection is run when out of list elements.
 * The car and cdr is saved accordingly. Other lists not bound to an atom
 * must be saved in advanced using lispgc_save_push().
 */
lispptr
_lisplist_get (lispptr car, lispptr cdr)
{
    lispptr ret;

    CHKPTR(car);
    CHKPTR(cdr);

    /* Avoid removal of register values by garbage-collection. */

    lispatom_ref (car);
    lispatom_ref (cdr);

    ret = lisplist_get_noref (car, cdr);
    lispgc_push (ret);

    /* Pop node from free list. */
    if (lisplist_num_used > (NUM_LISTNODES - 16)) {
	/* Collect garbage and try again, */
	lispgc_force ();
        if (lisplist_free_nodes == lispptr_nil)
	    lisperror_internal (lispptr_invalid, "no more free list elements");
    }

#ifdef LISP_GC_DEBUG
    if (lisp_is_initialized)
        lispgc_force ();
#endif

    lispgc_pop (); /* ret */
    return ret;
}

/* Return last cons of a list. */
lispptr
lisplist_last (lispptr l)
{
    RETURN_NIL(l);

    while (CDR(l) != lispptr_nil)
	l = CDR(l);

    return l;
}

/* Copy tree. */
lispptr
lisplist_copy_tree (lispptr l)
{
    lispptr car;
    lispptr cdr;
    lispptr ret;

    if (LISPPTR_IS_EXPR(l) == FALSE)
	return l;

    car = lisplist_copy_tree (CAR(l));
    lispgc_push (car);
    cdr = lisplist_copy_tree (CDR(l));
    ret = CONS(car, cdr);
    lispgc_pop ();

    return ret;
}

/*
 * Copy tree.
 *
 * Will run garbage collection when out of list elements. The argument is
 * saved. Use lispgc_save_push() for other unbound lists.
 */
lispptr
lisplist_copy (lispptr l)
{
    if (LISPPTR_IS_EXPR(l) == FALSE)
	return l;

    return CONS(CAR(l), lisplist_copy (CDR(l)));
}

/*
 * Remove element from list.
 *
 * The element is unlinked and left for garbage collection.
 */
lispptr
lisplist_delete (unsigned i, lispptr l)
{
    lispptr  p;
    lispptr  f = lispptr_nil;

    if (i == 0)
	return CDR(l);

    for (p = l; p != lispptr_nil; i--, p = CDR(p)) {
	if (i) {
	    f = p;
	    continue;
	}

	RPLACD(f, CDR(p));
	return l;
    }

    return lisperror (l, "lisplist_delete: index '%d' out of range", i);
}

/* Get zero-indexed position of element in list. */
int
lisplist_position (lispptr elt, lispptr l)
{
    int c = 0;

    while (l != lispptr_nil) {
	if (CAR(l) == elt)
	    return c;

        l = CDR(l);
	c++;
    }

    return -1;
}

/* Get length of a pure list. */
unsigned
lisplist_length (lispptr p)
{
    unsigned len = 0;

    while (p != lispptr_nil) {
	len++;
	p = CDR(p);
    }

    return len;
}

/* Return cons pointing to the nth element. */
lispptr
lisplist_nth (lispptr l, unsigned idx)
{
    while (l != lispptr_nil && idx--)
        l = CDR(l);

    if (l == lispptr_nil)
	return l;

    return CAR(l);
}

/* Sequence type: replace element at index. */
void
lisplist_t_set (lispptr s, unsigned idx, lispptr val)
{
    s = lisplist_nth (s, idx);

    RPLACA(s, val);
}

/* Sequence type: return element at index. */
lispptr
lisplist_t_get (lispptr s, unsigned idx)
{
    s = lisplist_nth (s, idx);

    return s;
}

/* Sequence type configuration. */
struct lisp_sequence_type lisplist_seqtype = {
	lisplist_t_set,
	lisplist_t_get,
	lisplist_length
};

/* Return T if all elements in a list are of the same type. */
bool
lisplist_check_type (lispptr list, unsigned type)
{
    for (; list != lispptr_nil; list = CDR(list))
        if (LISPPTR_TYPE(CAR(list)) != type)
	    return FALSE;

    return TRUE;
}

/* Append lst2 after lst. */
void
lisplist_append (lispptr *lst, lispptr lst2)
{
    lispptr tmp;

    if (lst2 == lispptr_nil)
	return;

#ifdef LISP_DIAGNOSTICS
    if (LISPPTR_IS_ATOM(lst2))
	lisperror_internal (lst2, "lisplist_append: can append list only");
#endif

    if (*lst == lispptr_nil) {
        *lst = lst2;
	return;
    }

    tmp = lisplist_last (*lst);
    RPLACD(tmp, lst2);
}

/* Copy list reversed. */
lispptr
lisplist_reverse (lispptr p)
{
    lispptr rev = lispptr_nil;

    if (p == lispptr_nil)
	return lispptr_nil;

    while (p != lispptr_nil) {
        rev = CONS(CAR(p), rev);                         
	p = CDR(p);
    }

    return rev;
}

/* Return T if trees have the same layout and contain the same elements. */
bool
lisplist_equal (lispptr la, lispptr lb)
{
    while (la != lispptr_nil && lb != lispptr_nil) {
        if (LISPPTR_IS_EXPR(la) != LISPPTR_IS_EXPR(lb))
	    return FALSE;

        if (LISPPTR_IS_EXPR(la) == FALSE)
	    return la == lb;

        if (lisplist_equal (CAR(la), CAR(lb)) == FALSE)
	    return FALSE;

	la = CDR(la);
	lb = CDR(lb);
    }

    return TRUE;
}

void
lisplist_init ()
{
    unsigned  i;

    /* Make a list of all elements. */
    for (i = 0; i < LAST_LISTNODE; i++) {
	lisp_lists[i].car = (lispptr) -23;
	lisp_lists[i].cdr = (lispptr) i + 1;
    }
    lisp_lists[LAST_LISTNODE].cdr = LISPPTR_NIL();

    lisplist_free_nodes = 0;
    lisplist_num_used = 0;

#ifdef LISP_DIAGNOSTICS
    bzero (lisplist_marks, sizeof (lisplist_marks));
#endif
}
