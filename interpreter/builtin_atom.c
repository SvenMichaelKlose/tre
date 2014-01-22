/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
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
#include "apply.h"
#include "gc.h"
#include "builtin_string.h"

treptr
treatom_symbolp (treptr object)
{
    return TREPTR_TRUTH(TREPTR_IS_SYMBOL(object));
}

treptr
treatom_functionp (treptr object)
{
    return TREPTR_TRUTH(TREPTR_IS_FUNCTION(object) ||
           TREPTR_IS_MACRO(object) ||
           TREPTR_IS_BUILTIN(object) ||
           IS_COMPILED_FUN(object) ||
           trebuiltin_is_compiled_closure (object));
}

treptr
treatom_builtinp (treptr object)
{
    return TREPTR_TRUTH(TREPTR_IS_BUILTIN(object));
}

treptr
treatom_macrop (treptr object)
{
    return TREPTR_TRUTH(TREPTR_IS_MACRO(object));
}

treptr
treatom_type_id (treptr object)
{
	return treatom_number_get (TREPTR_TYPE(object), TRENUMTYPE_INTEGER);
}

treptr
treatom_id (treptr object)
{
    return treatom_number_get (object, TRENUMTYPE_INTEGER);
}

treptr
treatom_builtin_not (treptr list)
{
	treptr x;

	do {
		x = CAR(list);
    	if (NOT_NIL(x))
            return treptr_nil;
		list = CDR(list);
	} while (NOT_NIL(list));

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
	} while (NOT_NIL(list));

	return treptr_t;
}

treptr
treatom_eql (treptr x, treptr y)
{
    treptr tmp;
   	if (TREPTR_IS_NUMBER(x)) {
       	if (TREPTR_IS_NUMBER(y) == FALSE)
    		return treptr_nil;
       	if (TRENUMBER_TYPE(x) != TRENUMBER_TYPE(y))
    		return treptr_nil;
       	RETURN_NIL(TREPTR_TRUTH(TRENUMBER_VAL(x) == TRENUMBER_VAL(y)));
   	} else if (TREPTR_IS_STRING(x)) {
       	if (TREPTR_IS_STRING(y) == FALSE)
    		return treptr_nil;
        tmp = CONS(y, treptr_nil);
        tregc_push (tmp);
        tmp = trestring_builtin_compare (CONS(x, tmp));
        tregc_pop ();
        return tmp;
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
	} while (NOT_NIL(list));

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
treatom_builtin_symbolp (treptr x)
{
    return treatom_symbolp (trearg_get (x));
}

treptr
treatom_builtin_functionp (treptr x)
{
    return treatom_functionp (trearg_get (x));
}

treptr
treatom_builtin_builtinp (treptr x)
{
    return treatom_builtinp (trearg_get (x));
}

treptr
treatom_builtin_macrop (treptr x)
{
    return treatom_macrop (trearg_get (x));
}

treptr
treatom_builtin_type_id (treptr x)
{
    return treatom_type_id (trearg_get (x));
}

treptr
treatom_builtin_id (treptr x)
{
    return treatom_id (trearg_get (x));
}
