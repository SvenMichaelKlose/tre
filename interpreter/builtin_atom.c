/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in atom-related functions
 */

#include "lisp.h"
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
lispptr
lispatom_builtin_eq (lispptr list)
{
    LISPLIST_DEFREGS();
    lisparg_get2 (&car, &cdr, list);

    return LISPPTR_TRUTH(car == cdr);
}

/*
 * (EQL o1 o2)
 *
 * Return T if the two objects are identical, or numbers with the same value.
 */
lispptr
lispatom_builtin_eql (lispptr list)
{
    LISPLIST_DEFREGS();
    lisparg_get2 (&car, &cdr, list);

    if (LISPPTR_IS_NUMBER(car)) {
        if (LISPPTR_IS_NUMBER(cdr) == FALSE)
	    return lispptr_nil;
        if (LISPNUMBER_TYPE(car) != LISPNUMBER_TYPE(cdr))
	    return lispptr_nil;
        return LISPPTR_TRUTH(LISPNUMBER_VAL(car) == LISPNUMBER_VAL(cdr));
    }

    return LISPPTR_TRUTH(car == cdr);
}

/*
 * (MAKE-SYMBOL string)
 *
 * Returns newly created self-referencing atom.
 */
lispptr
lispatom_builtin_make_symbol (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_STRING(arg) == FALSE)
        arg = lisperror (arg, "string expected");

    return lispatom_get (LISPATOM_STRINGP(arg), LISPCONTEXT_PACKAGE());
}

/*
 * (ATOM obj)
 *
 * Returns T if obj is not a cons.
 */
lispptr
lispatom_builtin_atom (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_EXPR(arg))
	return lispptr_nil;
    return lispptr_t;
}

lispptr
lispatom_builtin_arg (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_ATOM(arg) == FALSE)
	arg = lisperror (arg, "atom expected");

    return arg;
}

/*
 * (SYMBOL-VALUE obj)
 *
 * Returns value bound to atom.
 */
lispptr
lispatom_builtin_symbol_value (lispptr list)
{
    lispptr arg = lispatom_builtin_arg (list);
    return LISPATOM_VALUE(arg);
}

/*
 * (%ATOM-VALUE obj)
 *
 * Returns function bound to atom.
 */
lispptr
lispatom_builtin_atom_value (lispptr list)
{
    lispptr arg = lispatom_builtin_arg (list);
    return LISPATOM_VALUE(arg);
}


/*
 * (%ATOM-FUN obj)
 *
 * Returns function bound to atom.
 */
lispptr
lispatom_builtin_symbol_function (lispptr list)
{
    lispptr arg = lispatom_builtin_arg (list);
    return LISPATOM_FUN(arg);
}

/*
 * (%SET-ATOM-FUN obj)
 *
 * Set function of atom.
 */
lispptr
lispatom_builtin_set_atom_fun (lispptr list)
{
    LISPLIST_DEFREGS();
    lisparg_get2 (&car, &cdr, list);

    if (LISPPTR_IS_ATOM(car) == FALSE)
	return lisperror (car, "atom expected");

    cdr = lispeval (cdr);
    lispatom_set_function (car, cdr);
    return cdr;
}

/*
 * (%MKFUNCTIONATOM def)
 *
 * Returns new function atom.
 */
lispptr
lispatom_builtin_mkfunctionatom (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_EXPR(arg) == FALSE)
	return lisperror (arg, "list expected");
    return lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_FUNCTION, arg);
}

/*
 * (FUNCTIONP obj)
 *
 * Returns T if the argument is a number. NIL otherwise.
 */
lispptr
lispatom_builtin_functionp (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_FUNCTION(arg) || LISPPTR_IS_BUILTIN(arg))
	return lispptr_t;
    return lispptr_nil;
}

/*
 * (BOUNDP obj)
 *
 * Returns T if global symbol is bound to a variable.
 */
lispptr
lispatom_builtin_boundp (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPATOM_VALUE(arg) != arg)
	return lispptr_t;
    return lispptr_nil;
}

/*
 * (FBOUNDP obj)
 *
 * Returns T if global symbol is bound to a function.
 */
lispptr
lispatom_builtin_fboundp (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPATOM_FUN(arg) != lispptr_nil)
	return lispptr_t;
    return lispptr_nil;
}

/*
 * (MACROP obj)
 */
lispptr
lispatom_builtin_macrop (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_MACRO(arg))
	return lispptr_t;
    return lispptr_nil;
}

lispptr
lispatom_builtin_atom_list_s (lispptr ret)
{
    struct lisp_atom *a = lisp_atoms;
    unsigned  n;

    for (n = 0; n < NUM_ATOMS; n++) {
	if (a->type == ATOM_FUNCTION) {
            LISPLIST_PUSH(ret, TYPEINDEX_TO_LISPPTR(ATOM_FUNCTION, n));
	}
	a++;
    }
              
    return ret;
}

lispptr
lispatom_builtin_atom_list (lispptr no_args)
{
    (void) no_args;

    return lispatom_builtin_atom_list_s (lispptr_nil);
}
