/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in atom-related functions
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "error.h"
#include "argument.h"
#include "builtin_atom.h"
#include "string.h"
#include "thread.h"

/*
 * (EQ o1 o2)
 *
 * Return T if the two objects are identical, NIL otherwise.
 */
treptr
treatom_builtin_eq (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);

    return TREPTR_TRUTH(car == cdr);
}

/*
 * (EQL o1 o2)
 *
 * Return T if the two objects are identical, or numbers with the same value.
 */
treptr
treatom_builtin_eql (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);

    if (TREPTR_IS_NUMBER(car)) {
        if (TREPTR_IS_NUMBER(cdr) == FALSE)
	    return treptr_nil;
        if (TRENUMBER_TYPE(car) != TRENUMBER_TYPE(cdr))
	    return treptr_nil;
        return TREPTR_TRUTH(TRENUMBER_VAL(car) == TRENUMBER_VAL(cdr));
    }

    return TREPTR_TRUTH(car == cdr);
}

/*
 * (MAKE-SYMBOL string)
 *
 * Returns newly created self-referencing atom.
 */
treptr
treatom_builtin_make_symbol (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREPTR_IS_STRING(arg) == FALSE)
        arg = treerror (arg, "string expected");

    return treatom_get (TREATOM_STRINGP(arg), TRECONTEXT_PACKAGE());
}

/*
 * (ATOM obj)
 *
 * Returns T if obj is not a cons.
 */
treptr
treatom_builtin_atom (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREPTR_IS_EXPR(arg))
	return treptr_nil;
    return treptr_t;
}

treptr
treatom_builtin_arg (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREPTR_IS_ATOM(arg) == FALSE)
	arg = treerror (arg, "atom expected");

    return arg;
}

/*
 * (SYMBOL-VALUE obj)
 *
 * Returns value bound to atom.
 */
treptr
treatom_builtin_symbol_value (treptr list)
{
    treptr arg = treatom_builtin_arg (list);
    return TREATOM_VALUE(arg);
}

/*
 * (%ATOM-VALUE obj)
 *
 * Returns function bound to atom.
 */
treptr
treatom_builtin_atom_value (treptr list)
{
    treptr arg = treatom_builtin_arg (list);
    return TREATOM_VALUE(arg);
}


/*
 * (%ATOM-FUN obj)
 *
 * Returns function bound to atom.
 */
treptr
treatom_builtin_symbol_function (treptr list)
{
    treptr arg = treatom_builtin_arg (list);
    return TREATOM_FUN(arg);
}

/*
 * (%SET-ATOM-FUN obj)
 *
 * Set function of atom.
 */
treptr
treatom_builtin_set_atom_fun (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);

    if (TREPTR_IS_ATOM(car) == FALSE)
	return treerror (car, "atom expected");

    cdr = treeval (cdr);
    treatom_set_function (car, cdr);
    return cdr;
}

/*
 * (%MKFUNCTIONATOM def)
 *
 * Returns new function atom.
 */
treptr
treatom_builtin_mkfunctionatom (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREPTR_IS_EXPR(arg) == FALSE)
	return treerror (arg, "list expected");
    return treatom_alloc (NULL, TRECONTEXT_PACKAGE(), ATOM_FUNCTION, arg);
}

/*
 * (FUNCTIONP obj)
 *
 * Returns T if the argument is a number. NIL otherwise.
 */
treptr
treatom_builtin_functionp (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREPTR_IS_FUNCTION(arg) || TREPTR_IS_BUILTIN(arg))
	return treptr_t;
    return treptr_nil;
}

/*
 * (BOUNDP obj)
 *
 * Returns T if global symbol is bound to a variable.
 */
treptr
treatom_builtin_boundp (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREATOM_VALUE(arg) != arg)
	return treptr_t;
    return treptr_nil;
}

/*
 * (FBOUNDP obj)
 *
 * Returns T if global symbol is bound to a function.
 */
treptr
treatom_builtin_fboundp (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREATOM_FUN(arg) != treptr_nil)
	return treptr_t;
    return treptr_nil;
}

/*
 * (MACROP obj)
 */
treptr
treatom_builtin_macrop (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREPTR_IS_MACRO(arg))
	return treptr_t;
    return treptr_nil;
}

treptr
treatom_builtin_atom_list_s (treptr ret)
{
    struct tre_atom *a = tre_atoms;
    unsigned  n;

    for (n = 0; n < NUM_ATOMS; n++) {
	if (a->type == ATOM_FUNCTION) {
            TRELIST_PUSH(ret, TYPEINDEX_TO_TREPTR(ATOM_FUNCTION, n));
	}
	a++;
    }
              
    return ret;
}

treptr
treatom_builtin_atom_list (treptr no_args)
{
    (void) no_args;

    return treatom_builtin_atom_list_s (treptr_nil);
}
