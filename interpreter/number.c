/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Number atom related section.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "argument.h"

#include <ctype.h>

/* Number table. */
struct lisp_number lisp_numbers[NUM_NUMBERS];

/* Index list of unused numbers. */
lispptr lisp_numbers_unused;

#define NUMBER_SET(num, val, typ) \
    (num)->value = val; \
    (num)->type = typ;	/* unused */

#define LISPNUMBER_INDEX(ptr) 	((unsigned) LISPATOM_DETAIL(ptr))

/* Check if string contains a number. */
bool
lispnumber_is_value (char *symbol)
{
    unsigned  ndots = 0; /* Number of dots in string. */
    char      c;         /* Last read character. */

    if (*symbol == '-')
	symbol++;

    while ((c = *symbol++) != 0) {
	if (c == '.') {
	    if (ndots++)
	        return FALSE;
	    continue;
        }

	if (!isdigit (c))
	    return FALSE;
    }

    return TRUE;
}

/* Allocate number entry. */
unsigned
lispnumber_alloc (float value, int type)
{
    lispptr   next_free;
    unsigned  i;	/* number index */

    /* Add new number. */
    i = _CAR(lisp_numbers_unused);
    next_free = _CDR(lisp_numbers_unused);

    if (next_free == lispptr_nil) {
        lispgc_force ();
        next_free = _CDR(lisp_numbers_unused);
        if (next_free == lispptr_nil)
	    lisperror_internal (next_free, "out of numbers");
    }

    lisplist_free (lisp_numbers_unused);
    lisp_numbers_unused = next_free;
    NUMBER_SET(&lisp_numbers[i], value, type);

    return i;
}

/* Free number entry. */
void
lispnumber_free (lispptr n)
{
    unsigned  i; /* number index */

#ifdef LISP_DIAGNOSTICS
    if (LISPPTR_IS_NUMBER(n) == FALSE)
	lisperror_internal (n, "lispnumber_free(): not a number");
#endif

    i = LISPNUMBER_INDEX(n);
    lisp_numbers_unused = lisplist_get_noref (i, lisp_numbers_unused);
}

/* Initialise this section. */
void
lispnumber_init ()
{
    lispptr   p = lispptr_nil;
    unsigned  i;

    /* Put all numbers on free list. */
    for (i = NUM_NUMBERS - 1; i != (unsigned) -1; i--)
	p = lisplist_get_noref (i, p);
    lisp_numbers_unused = p;
}
