/*
 * tré – Copyright (c) 2005–2008,2012–2013 Sven Michael Klose <pixel@copei.de>
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

treptr
trearray_builtin_make (treptr sizes)
{
    treptr  i;

    if (sizes == treptr_nil)
		return treerror (sizes, "size(s) expexted");

    DOLIST(i, sizes)
        if (TREPTR_IS_NUMBER(CAR(i)) == FALSE)
	    	return treerror (CAR(i), "integer expected");

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

    for (i = indices, s = sizes;
			 i != treptr_nil && s != treptr_nil;
             i = CDR(i), s = CDR(s)) {
        tmp = TRENUMBER_VAL(CAR(i));
#if 0
        if (tmp < 0)
	    	return (tre_size) -1;
#endif

        ti += (long) tmp * r;
        r *= TRENUMBER_VAL(CAR(s));
		if (ti >= r) {
	    	trewarn (treptr_invalid, "index %d (arg %d) is larger than %d",
		      		 (tre_size) tmp, argnum, r - 1);
	    	return (tre_size) -1;
		}

        argnum++;
    }

    if (i != treptr_nil || s != treptr_nil)
        return (tre_size) -1;
    return ti;
}

treptr *
trearray_get_elt (treptr array, treptr indexes)
{
    treptr    sizes;
    treptr *  elts;
    tre_size  idx;

    if (indexes == treptr_nil)
		treerror (indexes, "index(es) expexted");

    if (trelist_check_type (indexes, TRETYPE_NUMBER) == FALSE)
		treerror (indexes, "integer expected");

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
    return TREPTR_TRUTH(TREPTR_IS_ARRAY(x));
}

treptr
trearray_builtin_p (treptr x)
{
    return trearray_p (trearg_get (x));
}

treptr
trearray_aref (treptr array, treptr indexes)
{
    treptr *  elts;

    if (array == treptr_nil)
		treerror (array, "array expexted");

    elts = trearray_get_elt (array, indexes);
    return !elts ?
               treerror (treptr_invalid, "index error") :
               *elts;
}

treptr
trearray_builtin_aref (treptr x)
{
    return trearray_aref (CAR(x), CDR(x));
}

treptr
trearray_set_aref (treptr val, treptr array, treptr indexes)
{
    treptr *  elts = trearray_get_elt (array, indexes);

    if (!elts)
        return treerror (treptr_invalid, "index error");
    return *elts = val;
}

treptr
trearray_builtin_set_aref (treptr x)
{
    return trearray_set_aref (CAR(x), CADR(x), CDDR(x));
}
