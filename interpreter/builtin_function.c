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
trefunction_builtin_arg (treptr list, int type, const char * descr)
{
    return trearg_typed (1, type, trearg_get (list), descr);
}

treptr
trefunction_builtin_function_native (treptr list)
{
    treptr arg = trefunction_builtin_arg (list, TRETYPE_FUNCTION, "SYMBOL-COMPILED-FUNCTION");
	return TREFUNCTION_NATIVE(arg) ? trenumber_get ((double) (long) TREFUNCTION_NATIVE(arg)) : treptr_nil;
}

treptr
trefunction_builtin_function_bytecode (treptr list)
{
    treptr arg = trefunction_builtin_arg (list, TRETYPE_FUNCTION, "FUNCTION-BYTECODE");
	return TREFUNCTION_BYTECODE(arg) ? treptr_nil : TREFUNCTION_BYTECODE(arg);
}

treptr
trefunction_builtin_usetf_function_bytecode (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return TREFUNCTION_BYTECODE(trearg_typed (2, TRETYPE_FUNCTION, cdr, "=-FUNCTION-BYTECODE")) =
                                trearg_typed (1, TRETYPE_ARRAY, car, "=-FUNCTION-BYTECODE");
}

treptr
trefunction_builtin_function_source (treptr list)
{
    treptr arg = trefunction_builtin_arg (list, TRETYPE_FUNCTION, "FUNCTION-BYTECODE");
	return TREFUNCTION_SOURCE(arg) ? TREFUNCTION_SOURCE(arg) : treptr_nil;
}
