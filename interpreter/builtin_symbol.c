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
#include "builtin_symbol.h"
#include "string2.h"
#include "thread.h"
#include "xxx.h"
#include "function.h"
#include "symtab.h"
#include "assert.h"
#include "symbol.h"

treptr
tresymbol_make (treptr name, treptr package)
{
    ASSERT_STRING(name);
    ASSERT_SYMBOL(package);
    return symbol_get_packaged (TREPTR_STRINGZ(name), package);
}

treptr
tresymbol_builtin_make_symbol (treptr args)
{
	size_t num_args = trelist_length (args);
	treptr name;
	treptr package;

	if (num_args == 0 || num_args > 2)
		args = treerror (treptr_nil, "Name and optional package required.");
    name = trearg_typed (1, TRETYPE_STRING, CAR(args), "MAKE-SYMBOL");
	package = num_args == 2 ? CADR(args) : TRECONTEXT_PACKAGE();

    return tresymbol_make (name, package);
}

treptr
tresymbol_builtin_make_package (treptr args)
{
	treptr name = trearg_typed (1, TRETYPE_STRING, trearg_get (args), "MAKE-PACKAGE");
	return TREPTR_STRINGLEN(name) == 0 ?
		       tre_package_keyword :
	           symbol_get (TREPTR_STRINGZ(name));
}

treptr
tresymbol_value (treptr symbol)
{
    ASSERT_SYMBOL(symbol);
    return SYMBOL_VALUE(symbol);
}

treptr
tresymbol_builtin_symbol_value (treptr list)
{
    return tresymbol_value (trearg_get (list));
}

treptr
tresymbol_set_value (treptr value, treptr symbol)
{
    ASSERT_SYMBOL(symbol);
    return SYMBOL_VALUE(symbol) = value;
}

treptr
tresymbol_builtin_usetf_symbol_value (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return tresymbol_set_value (car, cdr);
}

treptr
tresymbol_function (treptr symbol)
{
    ASSERT_SYMBOL(symbol);
    return SYMBOL_FUNCTION(symbol);
}

treptr
tresymbol_builtin_symbol_function (treptr list)
{
    return tresymbol_function (trearg_get (list));
}

treptr
tresymbol_set_function (treptr function, treptr symbol)
{
    ASSERT_SYMBOL(symbol);
    if (CALLABLEP(function))
        FUNCTION_NAME(function) = symbol;
    return SYMBOL_FUNCTION(symbol) = function;
}

treptr
tresymbol_builtin_usetf_symbol_function (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return tresymbol_set_function (car, cdr);
}

treptr
tresymbol_package (treptr symbol)
{
    ASSERT_SYMBOL(symbol);
    return SYMBOL_PACKAGE(symbol);
}

treptr
tresymbol_builtin_symbol_package (treptr list)
{
    return tresymbol_package (trearg_get (list));
}

treptr
tresymbol_builtin_set_atom_fun (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return tresymbol_set_function (eval (cdr), car);
}
