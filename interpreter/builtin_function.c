/*
 * tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <string.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "error.h"
#include "argument.h"
#include "builtin_function.h"
#include "string2.h"
#include "thread.h"
#include "xxx.h"
#include "function.h"
#include "symbol.h"

treptr
trefunction_native (treptr fun)
{
	return TREFUNCTION_NATIVE(fun) ? trenumber_get ((double) (long) TREFUNCTION_NATIVE(fun)) : treptr_nil;
}

treptr
trefunction_bytecode (treptr fun)
{
	return TREFUNCTION_BYTECODE(fun) ? TREFUNCTION_BYTECODE(fun) : treptr_nil;
}

treptr
trefunction_set_bytecode (treptr array, treptr fun)
{
    return TREFUNCTION_BYTECODE(fun) = array;
}

treptr
trefunction_source (treptr fun)
{
	return TREFUNCTION_SOURCE(fun) ? TREFUNCTION_SOURCE(fun) : treptr_nil;
}

treptr
trefunction_set_source (treptr list, treptr fun)
{
    return TREFUNCTION_SOURCE(fun) = list;
}

treptr
trefunction_make_function (treptr source)
{
    return trefunction_make (TRETYPE_FUNCTION, source);
}

treptr
trefunction_builtin_arg (treptr x, int type, const char * descr)
{
    return trearg_typed (1, type, trearg_get (x), descr);
}

treptr
trefunction_builtin_function_native (treptr x)
{
    return trefunction_native (trefunction_builtin_arg (x, TRETYPE_FUNCTION, "FUNCTION-NATIVE"));
}

treptr
trefunction_builtin_function_bytecode (treptr x)
{
    return trefunction_bytecode (trefunction_builtin_arg (x, TRETYPE_FUNCTION, "FUNCTION-BYTECODE"));
}

treptr
trefunction_builtin_usetf_function_bytecode (treptr x)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, x);
    return trefunction_set_bytecode(trearg_typed (1, TRETYPE_ARRAY, car, "=-FUNCTION-BYTECODE"),
                                    trearg_typed (2, TRETYPE_FUNCTION, cdr, "=-FUNCTION-BYTECODE"));
}

treptr
trefunction_builtin_function_source (treptr x)
{
    return trefunction_source (trefunction_builtin_arg (x, TRETYPE_FUNCTION, "FUNCTION-SOURCE"));
}

treptr
trefunction_builtin_set_source (treptr x)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, x);
    return trefunction_set_source(car, trearg_typed (2, TRETYPE_FUNCTION, cdr, "=-FUNCTION-SOURCE"));
}

treptr
trefunction_builtin_make_function (treptr source)
{
    treptr s = treptr_nil;

    if (NOT_NIL(source))
        s = trearg_get (source);
    return trefunction_make_function (s);
}
