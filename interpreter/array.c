/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Array related section.
 */

#include "config.h"
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
treptr *
trearray_get_raw (unsigned size)
{
    treptr  *array;

    array = trealloc (sizeof (treptr) * size);
    if (array == NULL)
	return NULL;

    /* Initialise elements. */
    while (size--)
	array[size] = treptr_nil;

    return array;
}

/* Get total size of array. */
unsigned
trearray_get_size (treptr sizes)
{
    treptr  a;
    treptr  car;
    unsigned      size = 1;

    DOLIST(a, sizes) {
	car = CAR(a);
	if (TREPTR_IS_NUMBER(car) == FALSE)
	    return treerror (car, "array size: number expected");
	size *= TRENUMBER_VAL(car);
    }

    return size;
}

/* Create array atom. */
treptr
trearray_get (treptr sizes)
{
    treptr   a;
    unsigned  size = trearray_get_size (sizes);

    a = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), ATOM_ARRAY, treptr_nil);
    treatom_set_value (a, trelist_copy (sizes));
    TREATOM_DETAIL(a) = trearray_get_raw (size);
    if (TREATOM_DETAIL(a) == NULL)
	return treerror (treptr_invalid, "out of memory");
    return a;
}

/*
 * Free array.
 *
 * The atom is not freed.
 */
void
trearray_free (treptr array)
{
    trealloc_free (TREATOM_DETAIL(array));
}

/* Sequence: Get value at index. */
treptr
trearray_t_get (treptr array, unsigned idx)
{
    treptr   adef = TREATOM_VALUE(array);
    unsigned  size = CAR(adef);
    treptr   *a = (treptr *) TREATOM_DETAIL(array);

    if (size <= idx)
        return treerror (array, "index %d out of range", idx);

    return a[idx];
}

void
trearray_set (treptr *a, unsigned idx, treptr val)
{
    if (a[idx] == val)
	return;

    a[idx] = val;
}

/* Sequence: replace value at index. */
void
trearray_t_set (treptr array, unsigned idx, treptr val)
{
    treptr   adef = TREATOM_VALUE(array);
    unsigned  size = CAR(adef);
    treptr   *a = (treptr *) TREATOM_DETAIL(array);

    if (size <= idx) {
        treerror (array, "index %d out of range", idx);
	return;
    }

    trearray_set (a, idx, val);
}

/* Sequence: Return length of array. */
unsigned
trearray_t_length (treptr array)
{
    return TREARRAY_SIZE(array);
}

/* Sequence type configuration. */
struct tre_sequence_type trearray_seqtype = {
    trearray_t_set,
    trearray_t_get,
    trearray_t_length
};
