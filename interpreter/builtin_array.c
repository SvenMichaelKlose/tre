/*
 * tré – Copyright (c) 2005–2008,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "alloc.h"
#include "argument.h"
#include "number.h"
#include "error.h"
#include "array.h"
#include "assert.h"

treptr
trearray_builtin_make (treptr sizes)
{
#ifndef TRE_NO_ASSERTIONS
    treptr  i;

    if (NOT(sizes))
		return treerror (sizes, "Size(s) expexted.");

    DOLIST(i, sizes)
        if (NUMBERP(CAR(i)) == FALSE)
	    	return treerror (CAR(i), "Integer expected.");
#endif

    return trearray_get (sizes);
}

tre_size
trearray_get_check_index (treptr indices, treptr sizes)
{
    treptr  i;
    treptr  s;
    tre_size  tmp;
    tre_size  ti = 0;
    tre_size  r = 1;
    tre_size  argnum = 2;

    for (i = indices, s = sizes; NOT_NIL(i) && NOT_NIL(s); i = CDR(i), s = CDR(s)) {
        tmp = TRENUMBER_VAL(CAR(i));

        ti += (long) tmp * r;
        r *= TRENUMBER_VAL(CAR(s));
#ifndef TRE_NO_ASSERTIONS
		if (ti >= r) {
	    	trewarn (treptr_invalid, "index %d (arg %d) is larger than %d",
		      		 (tre_size) tmp, argnum, r - 1);
	    	return (tre_size) -1;
		}
#endif

        argnum++;
    }

#ifndef TRE_NO_ASSERTIONS
    if (NOT_NIL(i) || NOT_NIL(s))
        return (tre_size) -1;
#endif

    return ti;
}

treptr *
trearray_get_elt (treptr array, treptr indexes)
{
    treptr    sizes;
    treptr *  elts;
    tre_size  idx;

    ASSERT_ARRAY(array);
    if (NOT(indexes))
		treerror (indexes, "Index(es) expexted.");
    if (list_check_type (indexes, TRETYPE_NUMBER) == FALSE)
		treerror (indexes, "Integer expected.");

    sizes = TREARRAY_SIZES(array);
    elts = TREARRAY_VALUES(array);

    idx = trearray_get_check_index (indexes, sizes);
    if (idx == (tre_size) -1)
		return NULL;
    return &elts[idx];
}

treptr
trearray_p (treptr x)
{
    return TREPTR_TRUTH(ARRAYP(x));
}

treptr
trearray_aref (treptr array, treptr indexes)
{
    treptr * elts = trearray_get_elt (array, indexes);

    return !elts ?
               treerror (treptr_invalid, "Index error.") :
               *elts;
}

treptr
trearray_set_aref (treptr val, treptr array, treptr indexes)
{
    treptr *  elts = trearray_get_elt (array, indexes);

    if (!elts)
        return treerror (treptr_invalid, "Index error.");
    return *elts = val;
}
