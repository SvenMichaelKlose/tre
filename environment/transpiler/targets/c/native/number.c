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
#include "cons.h"
#include "symtab.h"
#include "symbol.h"

treptr number_chars[256];

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
        tregc ();
    	i = malloc (sizeof (trenumber));
        if (!i)
	    	treerror_internal (NIL, "Out of memory for more numbers.");
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

treptr
number_get (double value, int type)
{
    treptr      atom;
    trenumber * num;

    num = trenumber_alloc (value, type);
    atom = atom_alloc (TRETYPE_NUMBER);
    ATOM(atom) = num;

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
    if (value < 0 || value > 255)
        return number_get (value, TRENUMTYPE_CHAR);
    return number_chars[(size_t) value];
}

float
trenumber_value (treptr x)
{
    return TRENUMBER_VAL(x);
}

void
trenumber_init ()
{
    int i;

    for (i = 0; i < 256; i++)
        EXPAND_UNIVERSE(number_chars[i] = number_get ((double) i, TRENUMTYPE_CHAR));
}
