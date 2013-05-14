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
#include "env.h"

void * tre_functions_free;
struct tre_function tre_functions[NUM_FUNCTIONS];

size_t
trefunction_alloc ()
{
    struct tre_function * i = trealloc_item (&tre_functions_free);

    if (!i) {
        tregc_force ();
    	i = trealloc_item (&tre_functions_free);
        if (!i)
	    	treerror_internal (treptr_nil, "out of functions");
    }

    i->source = treptr_nil;
    i->native = NULL;
    i->native_expander = NULL;

    return ((size_t) i - (size_t) tre_functions) / sizeof (struct tre_function);
}

void
trefunction_free (treptr x)
{
	trealloc_free_item (&tre_functions, &tre_functions[TREFUNCTION_INDEX(x)]);
}

treptr
trefunction_make ()
{
    treptr a = treatom_alloc (TRETYPE_FUNCTION);

    return a;                                                                                                                      
}

void
trefunction_init ()
{
	tre_functions_free = trealloc_item_init (&tre_functions, NUM_FUNCTIONS, sizeof (struct tre_function));
}
