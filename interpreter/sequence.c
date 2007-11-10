/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Generic sequences.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "string.h"
#include "eval.h"
#include "error.h"
#include "print.h"
#include "gc.h"
#include "sequence.h"
#include "argument.h"

#include "string.h"
#include "array.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>

struct tre_sequence_type *
tresequence_get_type (treptr seq)
{
    switch (TREPTR_TYPE(seq)) {
		case ATOM_STRING:
	    	return &trestring_seqtype;
		case ATOM_ARRAY:
	    	return &trearray_seqtype;
		case ATOM_EXPR:
	    	return &trelist_seqtype;
    }

    return NULL;
}

/*
 * (ELT index sequence)
 *
 * Return element of sequence (zero-indexed).
 */
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

    (*t->set) (seq, (unsigned) TRENUMBER_VAL(idx), val);

    return val;
}

/*
 * (ELT index sequence)
 *
 * Return element of sequence (zero-indexed).
 */
treptr
tresequence_builtin_elt (treptr args)
{
    struct tre_sequence_type *t;
    treptr  car;
    treptr  cdr;

    trearg_get2 (&car, &cdr, args);

    if (TREPTR_IS_NUMBER(cdr) == FALSE)
		return treerror (cdr, "index must be integer");

    t = tresequence_get_type (car);
    if (t == NULL)
        return treerror (car, "sequence expected");
    return (*t->get) (car, (unsigned) TRENUMBER_VAL(cdr));
}

/*
 * (LENGTH sequence)
 *
 * Return number of elements in sequence.
 */
treptr
tresequence_builtin_length (treptr args)
{
    treptr seq = trearg_get (args);
    struct tre_sequence_type *t;

    if (seq == treptr_nil)
		return treatom_number_get ((float) 0, TRENUMTYPE_INTEGER);

    t = tresequence_get_type (seq);
    if (t == NULL)
        return treerror (seq, "sequence expected");

    return treatom_number_get ((float) (*t->length) (seq), TRENUMTYPE_INTEGER);
}
