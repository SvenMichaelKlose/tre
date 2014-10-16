/*
 * tré – Copyright (c) 2005–2009,2013–2014 Sven Michael Klose <pixel@copei.de>
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

trenumber *
trenumber_alloc (double value, int type)
{
    trenumber * i = malloc (sizeof (trenumber));

    if (!i) {
        tregc_force ();
    	i = malloc (sizeof (trenumber));
        if (!i)
	    	treerror_internal (treptr_nil, "Out of memory for more numbers.");
    }
    i->value = value;
    i->type = type;

    return i;
}

void
trenumber_free (treptr n)
{
	free (TREPTR_NUMBER(n));
}

void
trenumber_init ()
{
}

treptr
number_get (double value, int type)
{
    treptr      atom;
    trenumber * num;

    num = trenumber_alloc (value, type);
    atom = treatom_alloc (TRETYPE_NUMBER);
    TREATOM(atom) = num;

    return atom;
}

treptr
number_get_float (double value)
{
    return number_get (value, TRENUMTYPE_FLOAT);
}

treptr
number_get_integer (double value)
{
    return number_get (value, TRENUMTYPE_INTEGER);
}

treptr
number_get_char (double value)
{
    return number_get (value, TRENUMTYPE_CHAR);
}
