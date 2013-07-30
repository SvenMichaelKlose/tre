/*
 * tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>
 */

#include <ctype.h>
#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "list.h"
#include "function.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "alloc.h"
#include "symbol.h"

struct tre_function *
trefunction_alloc ()
{
    struct tre_function * i = malloc (sizeof (struct tre_function));

    if (!i) {
        tregc_force ();
    	i = malloc (sizeof (struct tre_function));
        if (!i)
	    	treerror_internal (treptr_nil, "Out of memory for more functions.");
    }

    i->source = treptr_nil;
    i->bytecode = treptr_nil;
    i->native = NULL;
    i->native_expander = NULL;

    return i;
}

treptr
trefunction_make (tre_type type, treptr source)
{
    struct tre_function * i;
    treptr a;

    tregc_push (source);
    i = trefunction_alloc ();
    a = treatom_alloc (type);
    TREATOM_DETAIL(a) = i;
    TREFUNCTION_SOURCE(a) = source;
    tregc_pop ();

    return a;                                                                                                                      
}

void
trefunction_free (treptr x)
{
	free (TREPTR_FUNCTION(x));
}

void
trefunction_init ()
{
}
