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
#include "builtin_symbol.h"
#include "string2.h"
#include "thread.h"
#include "xxx.h"
#include "function.h"
#include "symbol.h"

treptr
tresymbol_make (treptr name, treptr package)
{
    return treatom_get (TREPTR_STRINGZ(name), package);
}

treptr
tresymbol_builtin_make_symbol (treptr args)
{
	size_t num_args = trelist_length (args);
	treptr name;
	treptr package;

	if (num_args == 0 || num_args > 2)
		args = treerror (treptr_nil, "name and optional package required");
    name = trearg_typed (1, TRETYPE_STRING, CAR(args), "MAKE-SYMBOL");
	package = num_args == 2 ? CADR(args) : TRECONTEXT_PACKAGE();

    return tresymbol_make (name, package);
}

treptr
tresymbol_builtin_make_package (treptr args)
{
	treptr name = trearg_typed (1, TRETYPE_STRING, trearg_get (args), "MAKE-PACKAGE");
	return strlen (TREPTR_STRINGZ(name)) == 0 ?
		       tre_package_keyword :
	           treatom_get (TREPTR_STRINGZ(name), TRECONTEXT_PACKAGE());
}

treptr
tresymbol_builtin_arg (treptr list, int type, const char * descr)
{
    return trearg_typed (1, type, trearg_get (list), descr);
}

treptr
tresymbol_value (treptr symbol)
{
    return TRESYMBOL_VALUE(symbol);
}

treptr
tresymbol_builtin_symbol_value (treptr list)
{
    return tresymbol_value (tresymbol_builtin_arg (list, TRETYPE_SYMBOL, "SYMBOL-VALUE"));
}

treptr
tresymbol_set_value (treptr value, treptr symbol)
{
    return treatom_set_value (symbol, value);
}

treptr
tresymbol_builtin_usetf_symbol_value (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return tresymbol_set_value (car, trearg_typed (2, TRETYPE_SYMBOL, cdr, "=-SYMBOL-VALUE"));
}

treptr
tresymbol_function (treptr symbol)
{
    return TRESYMBOL_FUN(symbol);
}

treptr
tresymbol_builtin_symbol_function (treptr list)
{
    return tresymbol_function (tresymbol_builtin_arg (list, TRETYPE_SYMBOL, "SYMBOL-FUNCTION"));
}

treptr
tresymbol_set_function (treptr function, treptr symbol)
{
    return treatom_set_function (symbol, function);
}

treptr
tresymbol_builtin_usetf_symbol_function (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return tresymbol_set_function (trearg_typed (2, TRETYPE_SYMBOL, cdr, "=-SYMBOL-FUNCTION"),
                                   trearg_typed (1, TRETYPE_FUNCTION, car, "=-SYMBOL-FUNCTION"));
}

treptr
tresymbol_package (treptr symbol)
{
    return TRESYMBOL_PACKAGE(symbol);
}

treptr
tresymbol_builtin_symbol_package (treptr list)
{
    return tresymbol_package (tresymbol_builtin_arg (list, TRETYPE_SYMBOL, "SYMBOL-PACKAGE"));
}

treptr
tresymbol_builtin_set_atom_fun (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return treatom_set_function (trearg_typed (1, TRETYPE_SYMBOL, car, "%SET-ATOM-FUN"), treeval (cdr));
}
