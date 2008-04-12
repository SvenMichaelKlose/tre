/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
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
    double  val;
	int     n = 1;

    arg = CAR(list);
    if (TREPTR_IS_NUMBER(arg) == FALSE)
        return treerror (arg, "not a number");
    val = TRENUMBER_VAL(arg);

	n = 2;
    list = CDR(list);
    while (list != treptr_nil) {
        arg = trearg_number (n++, "in arithmetic operation", CAR(list));
        val = (*func) (val, TRENUMBER_VAL(arg));
        list = CDR(list);
    }

    return treatom_number_get (val, TRENUMTYPE_FLOAT);
}

double treeval_op_plus (double a, double b) { return a + b; }
double treeval_op_difference (double a, double b) { return a - b; }
double treeval_op_times (double a, double b) { return a * b; }
double treeval_op_quotient (double a, double b) { return a / b; }
double treeval_op_logxor (double a, double b) { return (unsigned) a ^ (unsigned) b; }

/** section numbers **/

/**
    <cmd name="+" essential="yes">
        <args>
            <rest name="args"/>
        <args>
        <para>
            Returns the sum of args.
        </para>
    </cmd>
 */
treptr
trenumber_builtin_plus (treptr list)
{
    if (list == treptr_nil)
		return treatom_number_get (0, TRENUMTYPE_FLOAT);
    return treeval_exprop (list, treeval_op_plus);
}

/**
     <cmd name="-" essential="yes">
        <args>
            <rest name="args"/>
        <args>
        <para>
            When called with one argument, returns -nl. When called with
            additional arguments, they're substracted from nl.
        </para>
    </cmd>
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

/**
    <cmd name="*" essential="yes">
        <args>
            <rest name="args"/>
        <args>
        <para>
            When called without arguments, 1 is returned. Otherwise returns
            the product of the arguments.
        </para>
    </cmd>
 */
treptr
trenumber_builtin_times (treptr list)
{
    if (list == treptr_nil)
		return treatom_number_get (1, TRENUMTYPE_FLOAT);
    return treeval_exprop (list, treeval_op_times);
}

/**
    <cmd name="/" essential="yes">
        <args>
            <rest name="args"/>
        <args>
        <para>
            When called with one argument, 0 is returned. Otherwise returns
            the first argument divided by the rest.
        </para>
    </cmd>
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
	const char * descr = "in binary arithmetic operation";

    trearg_get2 (car, cdr, list);
	*car = trearg_number (1, descr, *car);
	*cdr = trearg_number (2, descr, *cdr);
}

/**
    <cmd name="MOD" essential="yes">
        <args>
            <arg name="x"/>
            <arg name="y"/>
        <args>
        <para>
            Returns the remainder of x divided by y.
        </para>
    </cmd>
 */
treptr
trenumber_builtin_mod (treptr list)
{
    TRELIST_DEFREGS();
    double    val;
    trenumber_builtin_args (&car, &cdr, list);

    val = fmod (TRENUMBER_VAL(car), TRENUMBER_VAL(cdr));
    return treatom_number_get (val, TRENUMTYPE_FLOAT);
}

/** section "Logical operators"
    <cmd name="LOGXOR">
        <args>
            <rest name="args"/>
        <args>
        <para>
            Exclusive OR numbers.
        </para>
    </cmd>
 */
treptr
trenumber_builtin_logxor (treptr list)
{
    if (list == treptr_nil)
		return treatom_number_get (0, TRENUMTYPE_FLOAT);
    return treeval_exprop (list, treeval_op_logxor);
}

/** section "Comparison" */

/**
    <cmd name="=" essential="yes>
        <args>
            <arg name="x"/>
            <arg name="y"/>
        <args>
        <para>
            Returns T if the values of x and y match.
        </para>
    </cmd>
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

/**
    <cmd name="<" essential="yes">
        <args>
            <arg name="x"/>
            <arg name="y"/>
        <args>
        <para>
            Returns T if number x is less than number y.
        </para>
    </cmd>
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

/**
    <cmd name=">">
        <args>
            <arg name="x"/>
            <arg name="y"/>
        <args>
        <para>
    Returns T if number x is greater than number y.
        </para>
    </cmd>
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
