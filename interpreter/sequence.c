/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Generic sequences.
 */

#include "lisp.h"
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

struct lisp_sequence_type *
lispsequence_get_type (lispptr seq)
{
    switch (LISPPTR_TYPE(seq)) {
	case ATOM_STRING:
	    return &lispstring_seqtype;
	case ATOM_ARRAY:
	    return &lisparray_seqtype;
	case ATOM_EXPR:
	    return &lisplist_seqtype;
    }

    return NULL;
}

/*
 * (ELT index sequence)
 *
 * Return element of sequence (zero-indexed).
 */
lispptr
lispsequence_builtin_set_elt (lispptr args)
{
    struct lisp_sequence_type *t;
    lispptr  val = CAR(args);
    lispptr  seq = CADR(args);
    lispptr  idx = CADDR(args);

    if (LISPPTR_IS_NUMBER(idx) == FALSE)
	return lisperror (idx, "index must be integer");

    t = lispsequence_get_type (seq);
    if (t == NULL)
        return lisperror (lispptr_invalid, "sequence expected");

    (*t->set) (seq, (unsigned) LISPNUMBER_VAL(idx), val);

    return val;
}

/*
 * (ELT index sequence)
 *
 * Return element of sequence (zero-indexed).
 */
lispptr
lispsequence_builtin_elt (lispptr args)
{
    struct lisp_sequence_type *t;
    lispptr  car;
    lispptr  cdr;

    lisparg_get2 (&car, &cdr, args);

    if (LISPPTR_IS_NUMBER(cdr) == FALSE)
	return lisperror (cdr, "index must be integer");

    t = lispsequence_get_type (car);
    if (t == NULL)
        return lisperror (car, "sequence expected");
    return (*t->get) (car, (unsigned) LISPNUMBER_VAL(cdr));
}

/*
 * (LENGTH sequence)
 *
 * Return number of elements in sequence.
 */
lispptr
lispsequence_builtin_length (lispptr args)
{
    lispptr seq = lisparg_get (args);
    struct lisp_sequence_type *t;

    if (seq == lispptr_nil)
	return lispatom_number_get ((float) 0, LISPNUMTYPE_INTEGER);

    t = lispsequence_get_type (seq);
    if (t == NULL)
        return lisperror (seq, "sequence expected");

    return lispatom_number_get ((float) (*t->length) (seq),
                                LISPNUMTYPE_INTEGER);
}
