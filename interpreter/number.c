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
#include "alloc.h"
#include "diag.h"

#include <ctype.h>

/* Number table. */
void * tre_numbers_free;
struct tre_number tre_numbers[NUM_NUMBERS];

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
trenumber_alloc (double value, int type)
{
	unsigned idx;

    void * i = trealloc_item (&tre_numbers_free,
                        &tre_numbers, &tre_numbers[NUM_NUMBERS]);

    if (!i) {
        tregc_force ();
    	i = trealloc_item (&tre_numbers_free,
                     	   &tre_numbers, &tre_numbers[NUM_NUMBERS]);
        if (!i)
	    	treerror_internal (treptr_nil, "out of numbers");
    }

    idx = ((unsigned) i - (unsigned) tre_numbers) / sizeof (struct tre_number);
    NUMBER_SET(&tre_numbers[idx], value, type);

    return idx;
}

/* Free number entry. */
void
trenumber_free (treptr n)
{
#ifdef TRE_DIAGNOSTICS
    if (TREPTR_IS_NUMBER(n) == FALSE)
		treerror_internal (n, "trenumber_free(): not a number");
#endif

	trealloc_free_item (&tre_numbers_free, &tre_numbers[TRENUMBER_INDEX(n)],
                        &tre_numbers, &tre_numbers[NUM_NUMBERS]);
}

/* Initialise this section. */
void
trenumber_init ()
{
	tre_numbers_free = trealloc_item_init (tre_numbers, NUM_NUMBERS, sizeof (struct tre_number));
}
