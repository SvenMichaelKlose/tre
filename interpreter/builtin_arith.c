/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in number-related functions
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "number.h"
#include "argument.h"
#include "builtin.h"
#include "builtin_number.h"

#include <math.h>

/* Perform operation over list. */
treptr
treeval_exprop (treptr list, treeval_opfunc_t func)
{
    treptr  arg;
    float    val;

    arg = CAR(list);
    if (TREPTR_IS_NUMBER(arg) == FALSE)
        return treerror (arg, "not a number");
    val = TRENUMBER_VAL(arg);

    list = CDR(list);
    while (list != treptr_nil) {
        arg = CAR(list);
        if (TREPTR_IS_NUMBER(arg) == FALSE)
            return treerror (arg, "not a number");

        val = (*func) (val, TRENUMBER_VAL(arg));

        list = CDR(list);
    }

    return treatom_number_get (val, TRENUMTYPE_FLOAT);
}

float treeval_op_plus (float a, float b) { return a + b; }
float treeval_op_difference (float a, float b) { return a - b; }
float treeval_op_times (float a, float b) { return a * b; }
float treeval_op_quotient (float a, float b) { return a / b; }
float treeval_op_logxor (float a, float b) { return (unsigned) a ^ (unsigned) b; }

/*
 * (+ &rest args)
 *
 * Returns the sum of args.
 */
treptr
trenumber_builtin_plus (treptr list)
{
    if (list == treptr_nil)
	return treatom_number_get (0, TRENUMTYPE_FLOAT);

    return treeval_exprop (list, treeval_op_plus);
}

/*
 * (- na &rest nd)
 *
 * When called with one argument, returns -nl. When called with
 * additional arguments, they're substracted from nl.
 */
treptr
trenumber_builtin_difference (treptr list)
{
    if (list == treptr_nil)
	return treerror (treptr_nil, "Argument expected");

    if (CDR(list) == treptr_nil)
	return treatom_number_get (-TREATOM_VALUE(CAR(list)), TRENUMTYPE_FLOAT);

    return treeval_exprop (list, treeval_op_difference);
}

/*
 * (* &rest args)
 *
 * When called without arguments, 1 is returned. Otherwise returns
 * the product of the arguments.
 */
treptr
trenumber_builtin_times (treptr list)
{
    if (list == treptr_nil)
	return treatom_number_get (1, TRENUMTYPE_FLOAT);

    return treeval_exprop (list, treeval_op_times);
}

/*
 * (/ na &rest args)
 *
 * When called with one argument, 0 is returned. Otherwise returns
 * the first argument divided by the rest.
 */
treptr
trenumber_builtin_quotient (treptr list)
{
    if (list == treptr_nil)
	return treerror (treptr_nil, "Argument expected");

    if (CDR(list) == treptr_nil)
	return treatom_number_get (1.0 / TREATOM_VALUE(CAR(list)), TRENUMTYPE_FLOAT);

    return treeval_exprop (list, treeval_op_quotient);
}

void
trenumber_builtin_args (treptr *car, treptr *cdr, treptr list)
{
    trearg_get2 (car, cdr, list);
    if (TREPTR_IS_NUMBER(*car) == FALSE)
	*car = treerror (*car, "first argument must be a number");
    if (TREPTR_IS_NUMBER(*cdr) == FALSE)
	*cdr = treerror (*cdr, "second argument must be a number");
}

/*
 * (MOD x y)
 *
 * Returns remainder of x / y.
 */
treptr
trenumber_builtin_mod (treptr list)
{
    TRELIST_DEFREGS();
    float    val;
    trenumber_builtin_args (&car, &cdr, list);

    val = fmod (TRENUMBER_VAL(car), TRENUMBER_VAL(cdr));
    return treatom_number_get (val, TRENUMTYPE_FLOAT);
}

/*
 * (LOGXOR &rest args)
 *
 * Returns the sum of args.
 */
treptr
trenumber_builtin_logxor (treptr list)
{
    if (list == treptr_nil)
	return treatom_number_get (0, TRENUMTYPE_FLOAT);

    return treeval_exprop (list, treeval_op_logxor);
}

/*
 * (EQUAL x y)
 *
 * Returns T if x and y are the same or if their values match.
 */
treptr
trenumber_builtin_number_equal (treptr list)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args (&car, &cdr, list);

    if (TRENUMBER_VAL(car) == TRENUMBER_VAL(cdr))
        return treptr_t;
    return treptr_nil;
}

/*
 * (< x y)
 *
 * Returns T if number x is less than number y.
 */
treptr
trenumber_builtin_lessp (treptr list)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args (&car, &cdr, list);

    if (TRENUMBER_VAL(car) < TRENUMBER_VAL(cdr))
        return treptr_t;
    return treptr_nil;
}

/*
 * (> x y) - builtin function
 *
 * Returns T if number x is greater than number y.
 */
treptr
trenumber_builtin_greaterp (treptr list)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args (&car, &cdr, list);

    if (TRENUMBER_VAL(car) > TRENUMBER_VAL(cdr))
        return treptr_t;
    return treptr_nil;
}
