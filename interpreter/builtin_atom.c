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
#include "builtin_atom.h"
#include "string2.h"
#include "thread.h"
#include "xxx.h"
#include "function.h"
#include "symbol.h"

treptr
treatom_builtin_not (treptr list)
{
	treptr x;

	do {
		x = CAR(list);
    	if (x != treptr_nil)
            return treptr_nil;
		list = CDR(list);
	} while (list != treptr_nil);

	return treptr_t;
}

treptr
treatom_builtin_eq (treptr list)
{
	treptr first;
	treptr x;

    first = CAR(list);
	list = CDR(list);
	do {
		x = CAR(list);
    	RETURN_NIL(TREPTR_TRUTH(first == x));
		list = CDR(list);
	} while (list != treptr_nil);

	return treptr_t;
}

treptr
treatom_eql (treptr x, treptr y)
{

   	if (TREPTR_IS_NUMBER(x)) {
       	if (TREPTR_IS_NUMBER(y) == FALSE)
    		return treptr_nil;
       	if (TRENUMBER_TYPE(x) != TRENUMBER_TYPE(y))
    		return treptr_nil;
       	RETURN_NIL(TREPTR_TRUTH(TRENUMBER_VAL(x) == TRENUMBER_VAL(y)));
   	} else
   		RETURN_NIL(TREPTR_TRUTH(x == y));

	return treptr_t;
}

treptr
treatom_builtin_eql (treptr list)
{
	treptr first;
	treptr x;

    first = CAR(list);
	list = CDR(list);
	do {
		x = CAR(list);
		RETURN_NIL(treatom_eql (first, x));
		list = CDR(list);
	} while (list != treptr_nil);

	return treptr_t;
}

treptr
treatom_builtin_atom (treptr list)
{
    treptr x;

	DOLIST(x, list)
        if (TREPTR_IS_CONS(CAR(x)))
		    return treptr_nil;
    return treptr_t;
}

treptr
treatom_builtin_arg (treptr list, int type, const char * descr)
{
    return trearg_typed (1, type, trearg_get (list), descr);
}

treptr
treatom_builtin_function_native (treptr list)
{
    treptr arg = treatom_builtin_arg (list, TRETYPE_FUNCTION, "SYMBOL-COMPILED-FUNCTION");
	return TREFUNCTION_NATIVE(arg) ? trenumber_get ((double) (long) TREFUNCTION_NATIVE(arg)) : treptr_nil;
}

treptr
treatom_builtin_function_bytecode (treptr list)
{
    treptr arg = treatom_builtin_arg (list, TRETYPE_FUNCTION, "FUNCTION-BYTECODE");
	return TREFUNCTION_BYTECODE(arg) ? treptr_nil : TREFUNCTION_BYTECODE(arg);
}

treptr
treatom_builtin_usetf_function_bytecode (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return TREFUNCTION_BYTECODE(trearg_typed (2, TRETYPE_FUNCTION, cdr, "=-FUNCTION-BYTECODE")) =
                                trearg_typed (1, TRETYPE_ARRAY, car, "=-FUNCTION-BYTECODE");
}

treptr
treatom_builtin_function_source (treptr list)
{
    treptr arg = treatom_builtin_arg (list, TRETYPE_FUNCTION, "FUNCTION-BYTECODE");
	return TREFUNCTION_SOURCE(arg) ? TREFUNCTION_SOURCE(arg) : treptr_nil;
}

treptr
treatom_builtin_symbolp (treptr list)
{
    treptr arg = trearg_get (list);
    return TREPTR_TRUTH(TREPTR_IS_SYMBOL(arg));
}

treptr
treatom_builtin_functionp (treptr list)
{
    treptr arg = trearg_get (list);
    return TREPTR_TRUTH(TREPTR_IS_FUNCTION(arg) || TREPTR_IS_MACRO(arg) || TREPTR_IS_BUILTIN(arg) || IS_COMPILED_FUN(arg));
}

treptr
treatom_builtin_builtinp (treptr list)
{
    return TREPTR_TRUTH(TREPTR_IS_BUILTIN(trearg_get (list)));
}

treptr
treatom_builtin_macrop (treptr list)
{
    return TREPTR_TRUTH(TREPTR_IS_MACRO(trearg_get (list)));
}

treptr
treatom_builtin_type_id (treptr args)
{
    treptr arg = trearg_get (args);
	return TREPTR_IS_CONS(arg) ?
               treatom_number_get (0, TRENUMTYPE_INTEGER) :
               treatom_number_get (TREATOM_TYPE(arg), TRENUMTYPE_INTEGER);
}

treptr
treatom_builtin_id (treptr args)
{
    return treatom_number_get (trearg_get (args), TRENUMTYPE_INTEGER);
}
