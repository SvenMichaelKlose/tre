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

size_t
trearray_get_check_index (treptr indices, treptr sizes)
{
    treptr  i;
    treptr  s;
    long    tmp;
    size_t  ti = 0;
    size_t  r = 1;
    size_t  argnum = 2;

    for (i = indices, s = sizes;
			 i != treptr_nil && s != treptr_nil;
             i = CDR(i), s = CDR(s)) {
        tmp = TRENUMBER_VAL(CAR(i));
        if (tmp < 0)
	    	return (size_t) -1;

        ti += (long) tmp * r;
        r *= TRENUMBER_VAL(CAR(s));
		if (ti >= r) {
	    	trewarn (treptr_invalid, "index %d (arg %d) is larger than %d",
		      		 (size_t) tmp, argnum, r - 1);
	    	return (size_t) -1;
		}

        argnum++;
    }

    if (i != treptr_nil || s != treptr_nil)
        return (size_t) -1;
    return ti;
}

treptr *
trearray_get_elt (treptr list)
{
    treptr    array;
    treptr    indices;
    treptr    sizes;
    treptr *  elts;
    size_t    idx;

    if (list == treptr_nil)
		treerror (list, "array expexted");
    if (CDR(list) == treptr_nil)
		treerror (list, "index(es) expexted");
    array = trearg_typed (1, TRETYPE_ARRAY, CAR(list), NULL);
    indices = CDR(list);

    if (trelist_check_type (indices, TRETYPE_NUMBER) == FALSE)
		treerror (indices, "integer expected");

    sizes = TREARRAY_SIZES(array);
    elts = TREARRAY_VALUES(array);

    idx = trearray_get_check_index (indices, sizes);
    if (idx == (size_t) -1)
		return NULL;
    return &elts[idx];
}

treptr
trearray_builtin_p (treptr list)
{
    treptr arg = trearg_get (list);

    return TREPTR_TRUTH(TREPTR_IS_ARRAY(arg));
}


treptr
trearray_builtin_aref (treptr list)
{
    treptr *  elts = trearray_get_elt (list);

    if (elts == NULL)
        return treerror (treptr_invalid, "index error");

    return *elts;
}

treptr
trearray_builtin_set_aref (treptr list)
{
    treptr    val = CAR(list);
    treptr *  elts = trearray_get_elt (CDR(list));

    if (elts == NULL)
        return treerror (treptr_invalid, "index error");

    *elts = val;

    return val;
}
