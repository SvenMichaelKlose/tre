/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>

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
#include "thread.h"
#include "gc.h"

struct tre_array *
trearray_get_raw (size_t size)
{
    struct tre_array * a;
    treptr * v;

    a = malloc (sizeof (struct tre_array));
    if (!a)
        return NULL;

    v = malloc (sizeof (treptr) * size);
    if (!v) {
        free (a);
		return NULL;
    }
    a->values = v;

    while (size--)
		v[size] = treptr_nil;

    return a;
}

size_t
trearray_get_size (treptr sizes)
{
    treptr a;
    treptr car;
    size_t size = 1;

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
    treptr a;
    struct tre_array * array;
    size_t  size = trearray_get_size (sizes);

    tregc_push (sizes);
    array = trearray_get_raw (size);
    if (!array) {
		tregc_force ();
    	array = trearray_get_raw (size);
        if (!array)
		    return treerror (treptr_invalid, "out of memory");
	}
    array->sizes = trelist_copy (sizes);
    tregc_push (array->sizes);
    a = treatom_alloc (TRETYPE_ARRAY);
    TREATOM_DETAIL(a) = array;
    tregc_pop ();
    tregc_pop ();
    return a;
}

treptr
trearray_make (size_t size)
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
    free (TREPTR_ARRAY(array)->values);
    free (TREPTR_ARRAY(array));
}

treptr
trearray_t_get (treptr array, size_t idx)
{
    size_t   size = TRENUMBER_VAL(CAR(TREARRAY_SIZES(array)));
    treptr * a = TREARRAY_VALUES(array);

    if (size <= idx)
        return treerror (array, "index %d out of range", idx);

    return a[idx];
}

void
trearray_t_set (treptr array, size_t idx, treptr val)
{
    size_t   size = TRENUMBER_VAL(CAR(TREARRAY_SIZES(array)));
    treptr * a = TREARRAY_VALUES(array);

    if (size <= idx) {
        treerror (array, "index %d out of range", idx);
		return;
    }

    a[idx] = val;
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
