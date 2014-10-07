/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>
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
#include "assert.h"

trearray *
trearray_alloc_raw (tre_size size)
{
    trearray *  a;
    treptr *    v;

    a = malloc (sizeof (trearray));
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

trearray *
trearray_alloc (tre_size size)
{
    trearray *  array = trearray_alloc_raw (size);

    if (!array) {
		tregc_force ();
    	array = trearray_alloc_raw (size);
    }

    return array;
}

tre_size
trearray_get_size (treptr sizes)
{
    treptr    a;
    treptr    car;
    tre_size  size = 1;

    _DOLIST(a, sizes) {
		car = _CAR(a);
		if (NUMBERP(car) == FALSE)
	    	return treerror (car, "Number expected for array size.");
		size *= TRENUMBER_VAL(car);
    }

    return size;
}

treptr
trearray_get (treptr sizes)
{
    trearray *  array;
    treptr      a;
    tre_size    size = trearray_get_size (sizes);

    array = trearray_alloc (size);
    if (!array)
        return treerror (treptr_invalid, "Cannot allocate array. Out of memory.");
    array->sizes = trelist_copy (sizes);
    tregc_push (array->sizes);
    a = treatom_alloc (TRETYPE_ARRAY);
    TREATOM(a) = array;
    tregc_pop ();

    return a;
}

treptr
trearray_make (tre_size size)
{
    return trearray_get (CONS(trenumber_get ((double) size), treptr_nil));
}

void
trearray_free (treptr array)
{
    free (TREPTR_ARRAY(array)->values);
    free (TREPTR_ARRAY(array));
}

treptr
trearray_t_get (treptr array, tre_size idx)
{
    tre_size  size;
    treptr *  a;
    ASSERT_ARRAY(array);

    size = TRENUMBER_VAL(CAR(TREARRAY_SIZES(array)));
    a = TREARRAY_VALUES(array);
    if (size <= idx)
        return treerror (array, "Index %d is out of range.", idx);
    return a[idx];
}

void
trearray_t_set (treptr array, tre_size idx, treptr val)
{
    tre_size  size;
    treptr *  a;
    ASSERT_ARRAY(array);

    size = TRENUMBER_VAL(CAR(TREARRAY_SIZES(array)));
    a = TREARRAY_VALUES(array);
    if (size <= idx) {
        treerror (array, "Index %d is out of range.", idx);
		return;
    }
    a[idx] = val;
}

tre_size
trearray_t_length (treptr array)
{
    ASSERT_ARRAY(array);
    return TREARRAY_SIZE(array);
}

struct tre_sequence_type trearray_seqtype = {
    trearray_t_set,
    trearray_t_get,
    trearray_t_length
};
