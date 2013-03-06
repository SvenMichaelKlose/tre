/*
 * tré – Copyright (c) 2005–2010,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "number.h"
#include "argument.h"
#include "builtin.h"
#include "builtin_number.h"
#include "builtin_string.h"

#include <math.h>
#include <string.h>
#include <stdlib.h>

treptr
treeval_exprop (treptr x, treeval_opfunc_t func, const char * descr)
{
    treptr  arg;
    double  val;
	long    n = 1;

    arg = CAR(x);
    if (TREPTR_IS_NUMBER(arg) == FALSE)
        return treerror (arg, "not a number");
    val = TRENUMBER_VAL(arg);

	n = 2;
    x = CDR(x);
    while (x != treptr_nil) {
        arg = trearg_typed (n++, TRETYPE_NUMBER, CAR(x), descr);
        val = (*func) (val, TRENUMBER_VAL(arg));
        x = CDR(x);
    }

    return treatom_number_get (val, TRENUMTYPE_FLOAT);
}

double treeval_op_plus       (double a, double b);
double treeval_op_difference (double a, double b);
double treeval_op_times      (double a, double b);
double treeval_op_quotient   (double a, double b);
double treeval_op_logxor     (double a, double b);

double treeval_op_plus       (double a, double b) { return a + b; }
double treeval_op_difference (double a, double b) { return a - b; }
double treeval_op_times      (double a, double b) { return a * b; }
double treeval_op_quotient   (double a, double b) { return a / b; }
double treeval_op_logxor     (double a, double b) { return (ulong) a ^ (ulong) b; }

treptr
trenumber_builtin_plus (treptr x)
{
    return x == treptr_nil ?
		       treatom_number_get (0, TRENUMTYPE_FLOAT) :
               treeval_exprop (x, treeval_op_plus, "+");
}

treptr
trenumber_builtin_character_plus (treptr x)
{
    return trenumber_code_char (trenumber_builtin_plus (x));
}

treptr
trenumber_builtin_difference (treptr x)
{
    if (x == treptr_nil)
		return treerror (treptr_nil, "Argument expected");

    if (CDR(x) == treptr_nil)
		return treatom_number_get (-TRENUMBER_VAL(CAR(x)), TRENUMTYPE_FLOAT);

    return treeval_exprop (x, treeval_op_difference, "-");
}

treptr
trenumber_builtin_character_difference (treptr x)
{
    return trenumber_code_char (trenumber_builtin_difference (x));
}

treptr
trenumber_builtin_times (treptr x)
{
    return x == treptr_nil ?
		       treatom_number_get (1, TRENUMTYPE_FLOAT) :
               treeval_exprop (x, treeval_op_times, "*");
}

treptr
trenumber_builtin_quotient (treptr x)
{
    if (x == treptr_nil)
		return treerror (treptr_nil, "Argument expected");

    if (CDR(x) == treptr_nil)
		return treatom_number_get (1.0 / TREATOM_VALUE(CAR(x)), TRENUMTYPE_FLOAT);

    return treeval_exprop (x, treeval_op_quotient, "/");
}

void
trenumber_builtin_args (char * name, treptr *car, treptr *cdr, treptr x)
{
    char descr[64];
	stpcpy (stpcpy (descr, "in binary arithmetic operation "), name);

    trearg_get2 (car, cdr, x);
	*car = trearg_typed (1, TRETYPE_NUMBER, *car, descr);
	*cdr = trearg_typed (2, TRETYPE_NUMBER, *cdr, descr);
}

treptr
trenumber_builtin_mod (treptr x)
{
    TRELIST_DEFREGS();
    double    val;
    trenumber_builtin_args ("MOD", &car, &cdr, x);

    val = fmod (TRENUMBER_VAL(car), TRENUMBER_VAL(cdr));
    return treatom_number_get (val, TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_logxor (treptr x)
{
    return x == treptr_nil ?
		       treatom_number_get (0, TRENUMTYPE_FLOAT) :
               treeval_exprop (x, treeval_op_logxor, "LOGXOR");
}

treptr
trenumber_builtin_number_equal (treptr x)
{
    TRELIST_DEFREGS();

	trearg_get2 (&car, &cdr, x);
    if (TREPTR_IS_STRING(car) || TREPTR_IS_STRING(cdr))
		return trestring_builtin_compare (x);

    trenumber_builtin_args ("==", &car, &cdr, x);
    return TREPTR_TRUTH(TRENUMBER_VAL(car) == TRENUMBER_VAL(cdr));
}

treptr
trenumber_builtin_lessp (treptr x)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args ("<", &car, &cdr, x);

    return TREPTR_TRUTH(TRENUMBER_VAL(car) < TRENUMBER_VAL(cdr));
}

treptr
trenumber_builtin_greaterp (treptr x)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args (">", &car, &cdr, x);

    return TREPTR_TRUTH(TRENUMBER_VAL(car) > TRENUMBER_VAL(cdr));
}

treptr
trenumber_builtin_sqrt (treptr x)
{
    return treatom_number_get (sqrt (TRENUMBER_VAL(trearg_get (x))), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_sin (treptr x)
{
    return treatom_number_get (sin (TRENUMBER_VAL(trearg_get (x))), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_cos (treptr x)
{
    return treatom_number_get (cos (TRENUMBER_VAL(trearg_get (x))), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_atan (treptr x)
{
    return treatom_number_get (atan (TRENUMBER_VAL(trearg_get (x))), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_atan2 (treptr x)
{
    treptr a;
    treptr b;

    trearg_get2 (&a, &b, x);

    return treatom_number_get (atan2 (TRENUMBER_VAL(a), TRENUMBER_VAL(b)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_random (treptr dummy)
{
    (void) dummy;

    return treatom_number_get ((float) random (), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_exp (treptr x)
{
    return treatom_number_get (expf (TRENUMBER_VAL(trearg_get (x))), TRENUMTYPE_FLOAT);
}
