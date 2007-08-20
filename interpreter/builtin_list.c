/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in list functions.
 */

#include "config.h"
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
treptr
trelist_builtin_cons (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return CONS(car, cdr);
}

/*
 * (LIST expression*)
 *
 * Returns copy of argument list.
 */
treptr
trelist_builtin_list (treptr list)
{
    return trelist_copy (list);
}

treptr
trelist_builtin_cxr_arg (treptr list)
{
    treptr arg = trearg_get (list);

    RETURN_NIL(arg);
    if (TREPTR_IS_EXPR(arg) == FALSE)
	return treerror (arg, "list expected");
    return arg;
}

/*
 * (CAR cons)
 *
 * Returns the CAR of a cons. Returns NIL if the cons is NIL.
 */
treptr
trelist_builtin_car (treptr list)
{
    treptr arg = trelist_builtin_cxr_arg (list);

    RETURN_NIL(arg);
    return CAR(arg);
}

/*
 * (CDR cons)
 *
 * Returns the CDR of a cons. Returns NIL if the cons is NIL.
 */
treptr
trelist_builtin_cdr (treptr list)
{
    treptr arg = trelist_builtin_cxr_arg (list);
    RETURN_NIL(arg);
    return CDR(arg);
}

#define TRELISTARG_GET2(cons, new, list) \
    treptr  cons;	\
    treptr  new;	\
    trearg_get2 (&cons, &new, list);	\
    if (TREPTR_IS_EXPR(cons) == FALSE)	\
        return treerror (cons, "1st argument is not an expression");

/*
 * (RPLACA list value)
 *
 * Set adress register of cons to new value.
 */
treptr
trelist_builtin_rplaca (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACA(cons, new);
    return cons;
}

/*
 * (RPLACD list value)
 *
 * Set decrement register of cons to new value.
 */
treptr
trelist_builtin_rplacd (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACD(cons, new);
    return cons;
}

/*
 * (CONSP obj)
 *
 * Returns T if the argument is a cons. NIL otherwise.
 */
treptr
trelist_builtin_consp (treptr list)
{
    treptr arg = trearg_get (list);

    if (TREPTR_IS_EXPR(arg))
	return treptr_t;
    return treptr_nil;
}
