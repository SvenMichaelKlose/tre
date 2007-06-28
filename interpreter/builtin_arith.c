/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in number-related functions
 */

#include "lisp.h"
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
lispptr
lispeval_exprop (lispptr list, lispeval_opfunc_t func)
{
    lispptr  arg;
    float    val;

    arg = CAR(list);
    if (LISPPTR_IS_NUMBER(arg) == FALSE)
        return lisperror (arg, "not a number");
    val = LISPNUMBER_VAL(arg);

    list = CDR(list);
    while (list != lispptr_nil) {
        arg = CAR(list);
        if (LISPPTR_IS_NUMBER(arg) == FALSE)
            return lisperror (arg, "not a number");

        val = (*func) (val, LISPNUMBER_VAL(arg));

        list = CDR(list);
    }

    return lispatom_number_get (val, LISPNUMTYPE_FLOAT);
}

float lispeval_op_plus (float a, float b) { return a + b; }
float lispeval_op_difference (float a, float b) { return a - b; }
float lispeval_op_times (float a, float b) { return a * b; }
float lispeval_op_quotient (float a, float b) { return a / b; }
float lispeval_op_logxor (float a, float b) { return (unsigned) a ^ (unsigned) b; }

/*
 * (+ &rest args)
 *
 * Returns the sum of args.
 */
lispptr
lispnumber_builtin_plus (lispptr list)
{
    if (list == lispptr_nil)
	return lispatom_number_get (0, LISPNUMTYPE_FLOAT);

    return lispeval_exprop (list, lispeval_op_plus);
}

/*
 * (- na &rest nd)
 *
 * When called with one argument, returns -nl. When called with
 * additional arguments, they're substracted from nl.
 */
lispptr
lispnumber_builtin_difference (lispptr list)
{
    if (list == lispptr_nil)
	return lisperror (lispptr_nil, "Argument expected");

    if (CDR(list) == lispptr_nil)
	return lispatom_number_get (-LISPATOM_VALUE(CAR(list)), LISPNUMTYPE_FLOAT);

    return lispeval_exprop (list, lispeval_op_difference);
}

/*
 * (* &rest args)
 *
 * When called without arguments, 1 is returned. Otherwise returns
 * the product of the arguments.
 */
lispptr
lispnumber_builtin_times (lispptr list)
{
    if (list == lispptr_nil)
	return lispatom_number_get (1, LISPNUMTYPE_FLOAT);

    return lispeval_exprop (list, lispeval_op_times);
}

/*
 * (/ na &rest args)
 *
 * When called with one argument, 0 is returned. Otherwise returns
 * the first argument divided by the rest.
 */
lispptr
lispnumber_builtin_quotient (lispptr list)
{
    if (list == lispptr_nil)
	return lisperror (lispptr_nil, "Argument expected");

    if (CDR(list) == lispptr_nil)
	return lispatom_number_get (1.0 / LISPATOM_VALUE(CAR(list)), LISPNUMTYPE_FLOAT);

    return lispeval_exprop (list, lispeval_op_quotient);
}

void
lispnumber_builtin_args (lispptr *car, lispptr *cdr, lispptr list)
{
    lisparg_get2 (car, cdr, list);
    if (LISPPTR_IS_NUMBER(*car) == FALSE)
	*car = lisperror (*car, "first argument must be a number");
    if (LISPPTR_IS_NUMBER(*cdr) == FALSE)
	*cdr = lisperror (*cdr, "second argument must be a number");
}

/*
 * (MOD x y)
 *
 * Returns remainder of x / y.
 */
lispptr
lispnumber_builtin_mod (lispptr list)
{
    LISPLIST_DEFREGS();
    float    val;
    lispnumber_builtin_args (&car, &cdr, list);

    val = fmod (LISPNUMBER_VAL(car), LISPNUMBER_VAL(cdr));
    return lispatom_number_get (val, LISPNUMTYPE_FLOAT);
}

/*
 * (LOGXOR &rest args)
 *
 * Returns the sum of args.
 */
lispptr
lispnumber_builtin_logxor (lispptr list)
{
    if (list == lispptr_nil)
	return lispatom_number_get (0, LISPNUMTYPE_FLOAT);

    return lispeval_exprop (list, lispeval_op_logxor);
}

/*
 * (EQUAL x y)
 *
 * Returns T if x and y are the same or if their values match.
 */
lispptr
lispnumber_builtin_number_equal (lispptr list)
{
    LISPLIST_DEFREGS();
    lispnumber_builtin_args (&car, &cdr, list);

    if (LISPNUMBER_VAL(car) == LISPNUMBER_VAL(cdr))
        return lispptr_t;
    return lispptr_nil;
}

/*
 * (< x y)
 *
 * Returns T if number x is less than number y.
 */
lispptr
lispnumber_builtin_lessp (lispptr list)
{
    LISPLIST_DEFREGS();
    lispnumber_builtin_args (&car, &cdr, list);

    if (LISPNUMBER_VAL(car) < LISPNUMBER_VAL(cdr))
        return lispptr_t;
    return lispptr_nil;
}

/*
 * (> x y) - builtin function
 *
 * Returns T if number x is greater than number y.
 */
lispptr
lispnumber_builtin_greaterp (lispptr list)
{
    LISPLIST_DEFREGS();
    lispnumber_builtin_args (&car, &cdr, list);

    if (LISPNUMBER_VAL(car) > LISPNUMBER_VAL(cdr))
        return lispptr_t;
    return lispptr_nil;
}
