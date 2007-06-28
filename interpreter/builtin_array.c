/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Array related section.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "sequence.h"
#include "array.h"
#include "argument.h"
#include "util.h"
#include "alloc.h"

/*
 * (MAKE-ARRAY n)
 *
 * Makes new array consisting of n elements.
 */
lispptr
lisparray_builtin_make (lispptr sizes)
{
    lispptr  i;

    if (sizes == lispptr_nil)
	return lisperror (sizes, "size(s) expexted");

    DOLIST(i, sizes)
        if (LISPPTR_IS_NUMBER(CAR(i)) == FALSE)
	    return lisperror (CAR(i), "integer expected");

    return lisparray_get (sizes);
}

/*
 * Get one-dimensional index.
 *
 * Checks if the number of indices are correct and if indices are in range.
 */
unsigned
lisparray_get_check_index (lispptr indices, lispptr sizes)
{
    lispptr  i;
    lispptr  s;
    int  tmp;
    unsigned  ti = 0;
    unsigned  r = 1;
    unsigned  argnum = 2;

    for (i = indices, s = sizes; i != lispptr_nil && s != lispptr_nil;
             i = CDR(i), s = CDR(s)) {
        tmp = LISPNUMBER_VAL(CAR(i));
        if (tmp < 0)
	    return (unsigned) -1;

        ti += (int) tmp * r;
        r *= LISPNUMBER_VAL(CAR(s));
	if (ti >= r) {
	    lispwarn (lispptr_invalid, "index %d (arg %d) is larger than %d",
		      (unsigned) tmp, argnum, r - 1);
	    return (unsigned) -1;
	}

        argnum++;
    }

    if (i != lispptr_nil || s != lispptr_nil)
        return (unsigned) -1;

    return ti;
}

lispptr *
lisparray_get_elt (lispptr list)
{
    lispptr  array;
    lispptr  indices;
    lispptr  sizes;
    lispptr  *elts;
    unsigned  idx;

    /* Get/check arguments. */
    if (list == lispptr_nil)
	lisperror (list, "array expexted");
    if (CDR(list) == lispptr_nil)
	lisperror (list, "index expexted");
    array = CAR(list);
    if (LISPPTR_IS_ARRAY(array) == FALSE)
	lisperror (array, "not an array");
    indices = CDR(list);

    /* Check that indices are integers. */
    if (lisplist_check_type (indices, ATOM_NUMBER) == FALSE)
	lisperror (indices, "integer expected");

    /* Get array definition and pointer to elements. */
    sizes = LISPATOM_VALUE(array);
    elts = LISPATOM_DETAIL(array);

    /* Get one dimensional index. */
    idx = lisparray_get_check_index (indices, sizes);
    if (idx == (unsigned) -1)
	return NULL;

    return &elts[idx];
}

lispptr
lisparray_builtin_p (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_ARRAY(arg))
        return lispptr_t;
    return lispptr_nil;
}


lispptr
lisparray_builtin_aref (lispptr list)
{
    lispptr *elts = lisparray_get_elt (list);

    if (elts == NULL)
        return lisperror (lispptr_invalid, "index error");

    /* Return element at index. */
    return *elts;
}

lispptr
lisparray_builtin_set_aref (lispptr list)
{
    lispptr  val = CAR(list);
    lispptr  *elts = lisparray_get_elt (CDR(list));
    if (elts == NULL)
        return lisperror (lispptr_invalid, "index error");

    if (*elts != val) {
        lispatom_unref (*elts);
        lispatom_ref (val);
        *elts = val;
    }

    return val;
}
