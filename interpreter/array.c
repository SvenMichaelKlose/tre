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
#include "thread.h"

/* Allocate and initialise array. */
lispptr *
lisparray_get_raw (unsigned size)
{
    lispptr  *array;

    array = lispalloc (sizeof (lispptr) * size);
    if (array == NULL)
	return NULL;

    /* Initialise elements. */
    lisp_atoms[0].refcnt += size;
    while (size--)
	array[size] = lispptr_nil;

    return array;
}

/* Get total size of array. */
unsigned
lisparray_get_size (lispptr sizes)
{
    lispptr  a;
    lispptr  car;
    unsigned      size = 1;

    DOLIST(a, sizes) {
	car = CAR(a);
	if (LISPPTR_IS_NUMBER(car) == FALSE)
	    return lisperror (car, "array size: number expected");
	size *= LISPNUMBER_VAL(car);
    }

    return size;
}

/* Create array atom. */
lispptr
lisparray_get (lispptr sizes)
{
    lispptr   a;
    unsigned  size = lisparray_get_size (sizes);

    a = lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_ARRAY, lispptr_nil);
    lispatom_set_value (a, lisplist_copy (sizes));
    LISPATOM_DETAIL(a) = lisparray_get_raw (size);
    if (LISPATOM_DETAIL(a) == NULL)
	return lisperror (lispptr_invalid, "out of memory");
    return a;
}

/*
 * Free array.
 *
 * The atom is not freed.
 */
void
lisparray_free (lispptr array)
{
    unsigned  size = LISPARRAY_SIZE(array);
    lispptr   *p = LISPATOM_DETAIL(array);

    /* Unref all elements in array. */
    while (size--)
	lispatom_unref (*p++);

    /* Free array and its definition. */
    lispalloc_free (LISPATOM_DETAIL(array));
}

/* Sequence: Get value at index. */
lispptr
lisparray_t_get (lispptr array, unsigned idx)
{
    lispptr   adef = LISPATOM_VALUE(array);
    unsigned  size = CAR(adef);
    lispptr   *a = (lispptr *) LISPATOM_DETAIL(array);

    if (size <= idx)
        return lisperror (array, "index %d out of range", idx);

    return a[idx];
}

void
lisparray_set (lispptr *a, unsigned idx, lispptr val)
{
    if (a[idx] == val)
	return;

    lispatom_unref (a[idx]);
    a[idx] = val;
    lispatom_ref (a[idx]);
}

/* Sequence: replace value at index. */
void
lisparray_t_set (lispptr array, unsigned idx, lispptr val)
{
    lispptr   adef = LISPATOM_VALUE(array);
    unsigned  size = CAR(adef);
    lispptr   *a = (lispptr *) LISPATOM_DETAIL(array);

    if (size <= idx) {
        lisperror (array, "index %d out of range", idx);
	return;
    }

    lisparray_set (a, idx, val);
}

/* Sequence: Return length of array. */
unsigned
lisparray_t_length (lispptr array)
{
    return LISPARRAY_SIZE(array);
}

/* Sequence type configuration. */
struct lisp_sequence_type lisparray_seqtype = {
    lisparray_t_set,
    lisparray_t_get,
    lisparray_t_length
};
