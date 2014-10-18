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
    treptr    v;
    tre_size  size = 1;

    _DOLIST(a, sizes) {
		v = CAR(a);
#ifndef TRE_NO_ASSERTIONS
		if (NUMBERP(v) == FALSE)
	    	return treerror (sizes, "Numbers expected as array dimensions.");
#endif
		size *= TRENUMBER_VAL(v);
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
    array->sizes = list_copy (sizes);
    tregc_push (array->sizes);
    a = treatom_alloc (TRETYPE_ARRAY);
    ATOM(a) = array;
    tregc_pop ();

    return a;
}

treptr
trearray_make (tre_size size)
{
    return trearray_get (CONS(number_get_float ((double) size), treptr_nil));
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
#ifndef TRE_NO_ASSERTIONS
    tre_size  size;
#endif
    treptr *  a;

    ASSERT_ARRAY(array);

    a = TREARRAY_VALUES(array);
#ifndef TRE_NO_ASSERTIONS
    size = TRENUMBER_VAL(CAR(TREARRAY_SIZES(array)));
    if (size <= idx)
        return treerror (array, "Index %d is out of range.", idx);
#endif

    return a[idx];
}

void
trearray_t_set (treptr array, tre_size idx, treptr val)
{
    treptr *  a;
#ifndef TRE_NO_ASSERTIONS
    tre_size  size;
#endif

    ASSERT_ARRAY(array);

    a = TREARRAY_VALUES(array);
#ifndef TRE_NO_ASSERTIONS
    size = TRENUMBER_VAL(CAR(TREARRAY_SIZES(array)));
    if (size <= idx) {
        treerror (array, "Index %d is out of range.", idx);
		return;
    }
#endif

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
