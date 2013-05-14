/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "string2.h"
#include "eval.h"
#include "error.h"
#include "print.h"
#include "gc.h"
#include "ptr.h"
#include "builtin_sequence.h"
#include "argument.h"
#include "array.h"
#include "xxx.h"

struct tre_sequence_type * tre_sequence_types [] = {
	&trelist_seqtype,	/* #define TRETYPE_CONS        0 */
	NULL,	            /* #define TRETYPE_SYMBOL      1 */
	NULL,	            /* #define TRETYPE_NUMBER      2 */
	&trestring_seqtype,	/* #define TRETYPE_STRING      3 */
	&trearray_seqtype,	/* #define TRETYPE_ARRAY       4 */
	NULL,	            /* #define TRETYPE_BUILTIN     5 */
	NULL,	            /* #define TRETYPE_SPECIAL     6 */
	NULL,	            /* #define TRETYPE_MACRO       7 */
	NULL,	            /* #define TRETYPE_FUNCTION    8 */
	NULL,	            /* #define TRETYPE_USERSPECIAL 9 */
};
	
struct tre_sequence_type *
tresequence_get_type (treptr seq)
{
	unsigned type = TREPTR_TYPE(seq);
	struct tre_sequence_type * seqtype;

	seqtype = tre_sequence_types[type];
	if (seqtype == NULL)
		treerror_norecover (seq, "not a sequence");
	
    return seqtype;
}

treptr
tresequence_builtin_set_elt (treptr args)
{
    struct tre_sequence_type *t;
    treptr  val = CAR(args);
    treptr  seq = CADR(args);
    treptr  idx = CADDR(args);

    if (TREPTR_IS_NUMBER(idx) == FALSE)
		return treerror (idx, "index must be integer");

    t = tresequence_get_type (seq);
    if (t == NULL)
        return treerror (treptr_invalid, "sequence expected");

    if (t->set == NULL)
        return treerror (seq, "sequence cannot be modified");
    (*t->set) (seq, (size_t) TRENUMBER_VAL(idx), val);

    return val;
}

treptr
tresequence_builtin_elt (treptr args)
{
    struct tre_sequence_type *t;
    treptr  seq;
    treptr  idx;

    trearg_get2 (&seq, &idx, args);

    if (TREPTR_IS_NUMBER(idx) == FALSE)
		return treerror (idx, "index must be integer");

	RETURN_NIL(seq);

    t = tresequence_get_type (seq);
    if (t == NULL)
        return treerror (seq, "sequence expected");
    return (*t->get) (seq, (size_t) TRENUMBER_VAL(idx));
}

treptr
tresequence_builtin_length (treptr args)
{
	treptr ret;
    treptr seq = trearg_get (args);
    struct tre_sequence_type *t;

    if (seq == treptr_nil)
		return treatom_number_get (0, TRENUMTYPE_INTEGER);

    t = tresequence_get_type (seq);
    if (t == NULL)
        return treerror (seq, "sequence expected");

    ret = treatom_number_get ((double) (*t->length) (seq), TRENUMTYPE_INTEGER);
	return ret;
}
