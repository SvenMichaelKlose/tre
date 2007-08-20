/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Number atom related section.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "argument.h"

#include <ctype.h>

/* Number table. */
struct tre_number tre_numbers[NUM_NUMBERS];

treptr tre_numbers_free;

#define NUMBER_SET(num, val, typ) \
    (num)->value = val; \
    (num)->type = typ;	/* unused */

#define TRENUMBER_INDEX(ptr) 	((unsigned) TREATOM_DETAIL(ptr))

/* Check if string contains a number. */
bool
trenumber_is_value (char *symbol)
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
trenumber_alloc (float value, int type)
{
    treptr   next_free;
    unsigned  i;	/* number index */

    /* Add new number. */
    i = _CAR(tre_numbers_free);
    next_free = _CDR(tre_numbers_free);

    if (next_free == treptr_nil) {
        tregc_force ();
        next_free = _CDR(tre_numbers_free);
        if (next_free == treptr_nil)
	    treerror_internal (next_free, "out of numbers");
    }

    trelist_free (tre_numbers_free);
    tre_numbers_free = next_free;
    NUMBER_SET(&tre_numbers[i], value, type);

    return i;
}

/* Free number entry. */
void
trenumber_free (treptr n)
{
    unsigned  i; /* number index */

#ifdef TRE_DIAGNOSTICS
    if (TREPTR_IS_NUMBER(n) == FALSE)
	treerror_internal (n, "trenumber_free(): not a number");
#endif

    i = TRENUMBER_INDEX(n);
    tre_numbers_free = CONS(i, tre_numbers_free);
}

/* Initialise this section. */
void
trenumber_init ()
{
    treptr   p = treptr_nil;
    unsigned  i;

    /* Put all numbers on free list. */
    for (i = NUM_NUMBERS - 1; i != (unsigned) -1; i--)
	p = CONS(i, p);
    tre_numbers_free = p;
}
