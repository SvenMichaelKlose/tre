/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
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
#include "builtin_string.h"

#include <math.h>

/* Perform operation over list. */
treptr
treeval_exprop (treptr list, treeval_opfunc_t func)
{
    treptr  arg;
    double  val;
	long    n = 1;

    arg = CAR(list);
    if (TREPTR_IS_NUMBER(arg) == FALSE)
        return treerror (arg, "not a number");
    val = TRENUMBER_VAL(arg);

	n = 2;
    list = CDR(list);
    while (list != treptr_nil) {
        arg = trearg_typed (n++, TRETYPE_NUMBER, CAR(list), "in arithmetic operation");
        val = (*func) (val, TRENUMBER_VAL(arg));
        list = CDR(list);
    }

    return treatom_number_get (val, TRENUMTYPE_FLOAT);
}

double treeval_op_plus (double a, double b) { return a + b; }
double treeval_op_difference (double a, double b) { return a - b; }
double treeval_op_times (double a, double b) { return a * b; }
double treeval_op_quotient (double a, double b) { return a / b; }
double treeval_op_logxor (double a, double b) { return (ulong) a ^ (ulong) b; }

/** section numbers **/

/*tredoc
  (cmd :name "NUMBER+" ::essential t
	(arg :name "args" :occurrence "rest")
	(para "Returns the sum of its arguments."))
*/
treptr
trenumber_builtin_plus (treptr list)
{
    if (list == treptr_nil)
		return treatom_number_get (0, TRENUMTYPE_FLOAT);
    return treeval_exprop (list, treeval_op_plus);
}

/*tredoc
  (cmd :name "NUMBER-" ::essential t
	(arg :name "args" :occurrence "rest")
	(para
      "When called with one argument, returns -nl. When called with"
      "additional arguments, they're substracted from nl."))
*/
treptr
trenumber_builtin_difference (treptr list)
{
    if (list == treptr_nil)
		return treerror (treptr_nil, "Argument expected");

    if (CDR(list) == treptr_nil)
		return treatom_number_get (-TREATOM_VALUE(CAR(list)),
								   TRENUMTYPE_FLOAT);

    return treeval_exprop (list, treeval_op_difference);
}

/*tredoc
  (cmd :name "*" :essential t
	(arg :name "args" :occurrence "rest")
	(para
      "When called without arguments, 1 is returned. Otherwise returns"
      "the product of the arguments."))
 */
treptr
trenumber_builtin_times (treptr list)
{
    if (list == treptr_nil)
		return treatom_number_get (1, TRENUMTYPE_FLOAT);
    return treeval_exprop (list, treeval_op_times);
}

/*tredoc
  (cmd :name "/" :essential t
	(arg :name "args" :occurrence "rest")
	(para
      "When called with one argument, 0 is returned. Otherwise returns"
      "the first argument divided by the rest."))
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
	*car = trearg_typed (1, TRETYPE_NUMBER, *car, descr);
	*cdr = trearg_typed (2, TRETYPE_NUMBER, *cdr, descr);
}

/*tredoc
  (cmd :name "MOD" :essential t
	(args
	  (arg :name "x")
	  (arg :name "y"))
	  (para "Returns the remainder of x divided by y."))
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

/*tredoc
  (cmd :name "LOGXOR"
	(arg :name "args" :occurrence "rest")
	(para "Exclusive OR numbers."))
 */
treptr
trenumber_builtin_logxor (treptr list)
{
    if (list == treptr_nil)
		return treatom_number_get (0, TRENUMTYPE_FLOAT);
    return treeval_exprop (list, treeval_op_logxor);
}

/*tredoc
  (cmd :name "=" :essential t
	(args
	  (arg :name "x")
	  (arg :name "y"))
    (para "Returns T if the values of x and y match."))
 */
treptr
trenumber_builtin_number_equal (treptr list)
{
    TRELIST_DEFREGS();

	trearg_get2 (&car, &cdr, list);
    if (TREPTR_IS_STRING(car) || TREPTR_IS_STRING(cdr))
		return trestring_builtin_compare (list);

    trenumber_builtin_args (&car, &cdr, list);
    if (TRENUMBER_VAL(car) == TRENUMBER_VAL(cdr))
        return treptr_t;

    return treptr_nil;
}

/*tredoc
  (cmd :name "<" :essential t
	(args
	  (arg :name "x")
	  (arg :name "y"))
    (para "Returns T if number x is less than number y."))
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

/*tredoc
  (cmd :name ">"
	(args
	  (arg :name "x")
	  (arg :name "y"))
	(para "Returns T if number x is greater than number y."))
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
