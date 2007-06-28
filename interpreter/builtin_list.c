/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in list functions.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "number.h"
#include "argument.h"
#include "builtin.h"
#include "builtin_list.h"
#include "xxx.h"

/*
 * (CONS car cdr)
 *
 * Returns a cons containing the first argument as the CAR
 * and the second argument as the CDR.
 */
lispptr
lisplist_builtin_cons (lispptr list)
{
    LISPLIST_DEFREGS();
    lisparg_get2 (&car, &cdr, list);
    return CONS(car, cdr);
}

/*
 * (LIST expression*)
 *
 * Returns copy of argument list.
 */
lispptr
lisplist_builtin_list (lispptr list)
{
    return lisplist_copy (list);
}

lispptr
lisplist_builtin_cxr_arg (lispptr list)
{
    lispptr arg = lisparg_get (list);

    RETURN_NIL(arg);
    if (LISPPTR_IS_EXPR(arg) == FALSE)
	return lisperror (arg, "list expected");
    return arg;
}

/*
 * (CAR cons)
 *
 * Returns the CAR of a cons. Returns NIL if the cons is NIL.
 */
lispptr
lisplist_builtin_car (lispptr list)
{
    lispptr arg = lisplist_builtin_cxr_arg (list);

    RETURN_NIL(arg);
    return CAR(arg);
}

/*
 * (CDR cons)
 *
 * Returns the CDR of a cons. Returns NIL if the cons is NIL.
 */
lispptr
lisplist_builtin_cdr (lispptr list)
{
    lispptr arg = lisplist_builtin_cxr_arg (list);
    RETURN_NIL(arg);
    return CDR(arg);
}

#define LISPLISTARG_GET2(cons, new, list) \
    lispptr  cons;	\
    lispptr  new;	\
    lisparg_get2 (&cons, &new, list);	\
    if (LISPPTR_IS_EXPR(cons) == FALSE)	\
        return lisperror (cons, "1st argument is not an expression");

/*
 * (RPLACA list value)
 *
 * Set adress register of cons to new value.
 */
lispptr
lisplist_builtin_rplaca (lispptr list)
{
    LISPLISTARG_GET2(cons, new, list);
    RPLACA(cons, new);
    return cons;
}

/*
 * (RPLACD list value)
 *
 * Set decrement register of cons to new value.
 */
lispptr
lisplist_builtin_rplacd (lispptr list)
{
    LISPLISTARG_GET2(cons, new, list);
    RPLACD(cons, new);
    return cons;
}

/*
 * (CONSP obj)
 *
 * Returns T if the argument is a cons. NIL otherwise.
 */
lispptr
lisplist_builtin_consp (lispptr list)
{
    lispptr arg = lisparg_get (list);

    if (LISPPTR_IS_EXPR(arg))
	return lispptr_t;
    return lispptr_nil;
}
