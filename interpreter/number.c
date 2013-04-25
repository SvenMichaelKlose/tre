/*
 * tré – Copyright (c) 2005–2009,2013 Sven Michael Klose <pixel@copei.de>
 */

#include <ctype.h>
#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "argument.h"
#include "alloc.h"

void * tre_numbers_free;
struct tre_number tre_numbers[NUM_NUMBERS];

#define NUMBER_SET(idx, val, typ) \
    tre_numbers[idx].value = val; \
    tre_numbers[idx].type = typ;

#define TRENUMBER_INDEX(ptr) 	((size_t) TREATOM_DETAIL(ptr))

bool
trenumber_is_value (char * symbol)
{
    size_t num_dots = 0;
	size_t len = 0;
    char  c;

    if (symbol[0] == '-' && symbol[1])
		symbol++;

    while ((c = *symbol++) != 0) {
		len++;
		if (c == '.') {
	    	if (num_dots++)
	        	return FALSE;
	    	continue;
        }

		if (!isdigit (c))
	    	return FALSE;
    }

	if (!len || (num_dots == 1 && len == 1))
		return FALSE;

    return TRUE;
}

size_t
trenumber_alloc (double value, int type)
{
	size_t idx;
    void * i = trealloc_item (&tre_numbers_free);

    if (!i) {
        tregc_force ();
    	i = trealloc_item (&tre_numbers_free);
        if (!i)
	    	treerror_internal (treptr_nil, "out of numbers");
    }

    idx = ((size_t) i - (size_t) tre_numbers) / sizeof (struct tre_number);
    NUMBER_SET(idx, value, type);

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
	tre_numbers_free = trealloc_item_init (&tre_numbers, NUM_NUMBERS, sizeof (struct tre_number));
}
