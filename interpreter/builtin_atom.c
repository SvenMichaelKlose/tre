/*
 * tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>
 */

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

#include <string.h>

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
treatom_builtin_make_symbol (treptr args)
{
	size_t num_args = trelist_length (args);
	treptr name;
	treptr package;

	if (num_args == 0 || num_args > 2)
		args = treerror (treptr_nil, "name and optional package required");
    name = trearg_typed (1, TRETYPE_STRING, CAR(args), "MAKE-SYMBOL");
	package = num_args == 2 ? CADR(args) : TRECONTEXT_PACKAGE();

    return treatom_get (TREATOM_STRINGP(name), package);
}


treptr
treatom_builtin_make_package (treptr args)
{
	treptr name = trearg_typed (1, TRETYPE_STRING, trearg_get (args), "MAKE-PACKAGE");
	return strlen (TREATOM_STRINGP(name)) == 0 ?
		       tre_package_keyword :
	           treatom_get (TREATOM_STRINGP(name), TRECONTEXT_PACKAGE()); /* TREATOM_SET_TYPE(atom, TRETYPE_PACKAGE); */
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
treatom_builtin_arg (treptr list, const char * descr)
{
    return trearg_typed (1, TRETYPE_ATOM, trearg_get (list), descr);
}

treptr
treatom_builtin_symbol_value (treptr list)
{
    return TREATOM_VALUE(treatom_builtin_arg (list, "SYMBOL-VALUE"));
}

treptr
treatom_builtin_usetf_symbol_value (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return treatom_set_value (trearg_typed (2, TRETYPE_ATOM, cdr, "SETF SYMBOL-VALUE"), car);
}

treptr
treatom_builtin_setq_atom_value (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return treatom_set_value (trearg_typed (1, TRETYPE_ATOM, car, "SETF SYMBOL-VALUE"), cdr);
}

treptr
treatom_builtin_symbol_function (treptr list)
{
    treptr arg = treatom_builtin_arg (list, "SYMBOL-FUNCTION");
	return TREPTR_IS_BUILTIN(arg) ? arg : TREATOM_FUN(arg);
}

treptr
treatom_builtin_symbol_package (treptr list)
{
    return TREATOM_PACKAGE(treatom_builtin_arg (list, "SYMBOL-PACKAGE"));
}

treptr
treatom_builtin_symbol_compiled_function (treptr list)
{
    treptr arg = treatom_builtin_arg (list, "SYMBOL-COMPILED-FUNCTION");
	return TREATOM_COMPILED_FUN(arg) ? trenumber_get ((double) (long) TREATOM_COMPILED_FUN(arg)) : treptr_nil;
}

treptr
treatom_builtin_usetf_symbol_function (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return treatom_set_function (trearg_typed (1, TRETYPE_ATOM, cdr, "(SETF SYMBOL-FUNCTION"), car);
}

treptr
treatom_builtin_set_atom_fun (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return treatom_set_function (trearg_typed (1, TRETYPE_ATOM, car, "%SET-ATOM-FUN"), treeval (cdr));
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
