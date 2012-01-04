/*
 * tré - Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "builtin_sequence.h"
#include "array.h"
#include "argument.h"
#include "util.h"
#include "alloc.h"
#include "thread.h"
#include "gc.h"

/* Allocate and initialise array. */
treptr *
trearray_get_raw (ulong size)
{
    treptr  * array;

    array = trealloc (sizeof (treptr) * size);
    if (array == NULL)
		return NULL;

    /* Initialise elements. */
    while (size--)
		array[size] = treptr_nil;

    return array;
}

/* Get total size of array. */
ulong
trearray_get_size (treptr sizes)
{
    treptr  a;
    treptr  car;
    ulong   size = 1;

    _DOLIST(a, sizes) {
		car = _CAR(a);
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
    treptr  a;
    ulong   size = trearray_get_size (sizes);

    a = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), TRETYPE_ARRAY, treptr_nil);
    treatom_set_value (a, trelist_copy (sizes));
    TREATOM_DETAIL(a) = trearray_get_raw (size);
    if (TREATOM_DETAIL(a) == NULL) {
		tregc_force ();
    	TREATOM_DETAIL(a) = trearray_get_raw (size);
        if (TREATOM_DETAIL(a) == NULL)
		    return treerror (treptr_invalid, "out of memory");
	}
    return a;
}

#include "gc.h"

/* Create a one-dimensional array for compiled code. */
treptr
trearray_make (ulong size)
{
	treptr n;
	treptr s;
	treptr ret;

	n = trenumber_get ((double) size);
	tregc_push (n);
	s = CONS(n, treptr_nil);
	tregc_push (s);
	ret = trearray_get (s);
	tregc_pop ();
	tregc_pop ();

    return ret;
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
trearray_t_get (treptr array, ulong idx)
{
    treptr  adef = TREATOM_VALUE(array);
    ulong 	size = CAR(adef);
    treptr  * a = (treptr *) TREATOM_DETAIL(array);

    if (size <= idx)
        return treerror (array, "index %d out of range", idx);

    return a[idx];
}

void
trearray_set (treptr *a, ulong idx, treptr val)
{
    if (a[idx] == val)
		return;

    a[idx] = val;
}

/* Sequence: replace value at index. */
void
trearray_t_set (treptr array, ulong idx, treptr val)
{
    treptr  adef = TREATOM_VALUE(array);
    ulong   size = CAR(adef);
    treptr  * a = (treptr *) TREATOM_DETAIL(array);

    if (size <= idx) {
        treerror (array, "index %d out of range", idx);
		return;
    }

    trearray_set (a, idx, val);
}

/* Sequence: Return length of array. */
size_t
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
