/*
 * tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <ctype.h>
#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "function.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "alloc.h"
#include "symtab.h"
#include "symbol.h"

treptr treptr_closure;

bool
is_compiled_closure (treptr x)
{
    return CONSP(x) && CAR(x) == treptr_closure;
}

trefunction *
trefunction_alloc ()
{
    trefunction * i = malloc (sizeof (trefunction));

    if (!i) {
        tregc_force ();
    	i = malloc (sizeof (trefunction));
        if (!i)
	    	treerror_internal (treptr_nil, "Out of memory for more functions.");
    }

    i->name = treptr_nil;
    i->source = treptr_nil;
    i->bytecode = treptr_nil;
    i->native = NULL;
    i->native_expander = NULL;

    return i;
}

treptr
trefunction_make (tre_type type, treptr source)
{
    treptr        a;

    a = treatom_alloc (type);
    tregc_push (a);
    ATOM(a) = trefunction_alloc ();
    FUNCTION_SOURCE(a) = source;
    tregc_pop ();

    return a;                                                                                                                      
}

void
trefunction_free (treptr x)
{
	free (TREPTR_FUNCTION(x));
}

void
function_init ()
{
    treptr_closure = symbol_get ("%CLOSURE");
    EXPAND_UNIVERSE(treptr_closure);
}
