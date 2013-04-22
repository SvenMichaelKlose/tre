/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "cons.h"
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

treptr *
trearray_get_raw (ulong size)
{
    treptr  * array;

    array = trealloc (sizeof (treptr) * size);
    if (array == NULL)
		return NULL;

    while (size--)
		array[size] = treptr_nil;

    return array;
}

size_t
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

treptr
trearray_get (treptr sizes)
{
    treptr  a;
    ulong   size = trearray_get_size (sizes);
    treptr  * array;
    treptr  copied_sizes;

    array = trearray_get_raw (size);
    if (!array) {
		tregc_force ();
    	array = trearray_get_raw (size);
        if (!array)
		    return treerror (treptr_invalid, "out of memory");
	}
    copied_sizes = trelist_copy (sizes);
    tregc_push (copied_sizes);
    a = treatom_alloc (TRETYPE_ARRAY);
    tregc_push (a);
    treatom_set_value (a, copied_sizes);
    TREATOM_DETAIL(a) = array;
    tregc_pop ();
    tregc_pop ();
    return a;
}

treptr
trearray_make (ulong size)
{
	treptr n;
	treptr s;
	treptr ret;

	n = trenumber_get ((double) size);
	s = CONS(n, treptr_nil);
	tregc_push (s);
	ret = trearray_get (s);
	tregc_pop ();

    return ret;
}

void
trearray_free (treptr array)
{
    trealloc_free (TREATOM_DETAIL(array));
}

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

size_t
trearray_t_length (treptr array)
{
    return TREARRAY_SIZE(array);
}

struct tre_sequence_type trearray_seqtype = {
    trearray_t_set,
    trearray_t_get,
    trearray_t_length
};
