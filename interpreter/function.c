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

treptr
register_compiled_function (treptr sym, void * fun, void * argument_expander)
{
    if (BUILTINP(SYMBOL_FUNCTION(sym)))
        return sym;

    if (NOT(SYMBOL_FUNCTION(sym)))
        tresymbol_set_function (trefunction_make (TRETYPE_FUNCTION, NIL), sym);

    FUNCTION_NATIVE(SYMBOL_FUNCTION(sym)) = fun;
    FUNCTION_NATIVE_EXPANDER(SYMBOL_FUNCTION(sym)) = argument_expander;

    return sym;
}

trefunction *
trefunction_alloc ()
{
    trefunction * i = malloc (sizeof (trefunction));

    if (!i) {
        tregc_force ();
    	i = malloc (sizeof (trefunction));
        if (!i)
	    	treerror_internal (NIL, "Out of memory for more functions.");
    }

    i->name = NIL;
    i->source = NIL;
    i->bytecode = NIL;
    i->native = NULL;
    i->native_expander = NULL;

    return i;
}

treptr
trefunction_make (tre_type type, treptr source)
{
    treptr        a;

    a = atom_alloc (type);
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
