/*
 * tré – Copyright (c) 2005-2009,2013 Sven Michael Klose <pixel@copei.de>
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

#include <ctype.h>

void * tre_numbers_free;
struct tre_number tre_numbers[NUM_NUMBERS];

#define NUMBER_SET(num, val, typ) \
    (num)->value = val; \
    (num)->type = typ;	/* unused */

#define TRENUMBER_INDEX(ptr) 	((ulong) TREATOM_DETAIL(ptr))

bool
trenumber_is_value (char *symbol)
{
    ulong   ndots = 0;	/* Number of dots in string. */
	ulong	len = 0;	/* Length of symbol. */
    char    c;        	/* Last read character. */

    if (*symbol == '-' && symbol[1] != 0)
		symbol++;

    while ((c = *symbol++) != 0) {
		len++;
		if (c == '.') {
	    	if (ndots++)
	        	return FALSE;
	    	continue;
        }

		if (!isdigit (c))
	    	return FALSE;
    }

	if (ndots == 1 && len == 1)
		return FALSE;

    return TRUE;
}

ulong
trenumber_alloc (double value, int type)
{
	ulong idx;

    void * i = trealloc_item (&tre_numbers_free);

    if (!i) {
        tregc_force ();
    	i = trealloc_item (&tre_numbers_free);
        if (!i)
	    	treerror_internal (treptr_nil, "out of numbers");
    }

    idx = ((ulong) i - (ulong) tre_numbers) / sizeof (struct tre_number);
    NUMBER_SET(&tre_numbers[idx], value, type);

    return idx;
}

void
trenumber_free (treptr n)
{
	trealloc_free_item (&tre_numbers_free, &tre_numbers[TRENUMBER_INDEX(n)]);
}

void
trenumber_init ()
{
	tre_numbers_free = trealloc_item_init (tre_numbers, NUM_NUMBERS, sizeof (struct tre_number));
}
