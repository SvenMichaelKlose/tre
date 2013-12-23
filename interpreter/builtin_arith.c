/*
 * tré – Copyright (c) 2005–2010,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <math.h>
#include <string.h>
#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "number.h"
#include "argument.h"
#include "symbol.h"
#include "builtin.h"
#include "builtin_number.h"
#include "builtin_string.h"

treptr
treeval_exprop (treptr x, treeval_opfunc_t func, const char * descr)
{
    treptr  arg;
    double  val;
	long    n = 1;

    arg = CAR(x);
    if (TREPTR_IS_NUMBER(arg) == FALSE)
        return treerror (arg, "Not a number.");
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
double treeval_op_logxor     (double a, double b) { return (size_t) a ^ (size_t) b; }

treptr
trenumber_builtin_plus (treptr x)
{
    return NOT(x) ?
		       treatom_number_get (0, TRENUMTYPE_FLOAT) :
               treeval_exprop (x, treeval_op_plus, "+");
}

treptr
trenumber_plus (treptr a, treptr b)
{
    return treatom_number_get (TRENUMBER_VAL(a) + TRENUMBER_VAL(b), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_character_plus (treptr x)
{
    return trenumber_code_char (trenumber_builtin_plus (x));
}

treptr
trenumber_difference (treptr a, treptr b)
{
    return treatom_number_get (TRENUMBER_VAL(a) - TRENUMBER_VAL(b), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_difference (treptr x)
{
    if (NOT(x))
		return treerror (treptr_nil, "Argument expected.");
    if (NOT(CDR(x)))
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
    return NOT(x) ?
		       treatom_number_get (1, TRENUMTYPE_FLOAT) :
               treeval_exprop (x, treeval_op_times, "*");
}

treptr
trenumber_builtin_quotient (treptr x)
{
    if (NOT(x))
		return treerror (treptr_nil, "Argument expected.");
    if (NOT(CDR(x)))
		return treatom_number_get (1.0 / TRESYMBOL_VALUE(CAR(x)), TRENUMTYPE_FLOAT);

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
trenumber_mod (treptr x, treptr mod)
{
    return treatom_number_get (fmod (TRENUMBER_VAL(x), TRENUMBER_VAL(mod)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_mod (treptr x)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args ("MOD", &car, &cdr, x);

    return trenumber_mod (car, cdr);
}

treptr
trenumber_builtin_logxor (treptr x)
{
    return NOT(x) ?
		       treatom_number_get (0, TRENUMTYPE_FLOAT) :
               treeval_exprop (x, treeval_op_logxor, "LOGXOR");
}

treptr
trenumber_equal (treptr a, treptr b)
{
    return TREPTR_IS_STRING(a) || TREPTR_IS_STRING(b) ?
               trestring_builtin_compare (CONS(a, CONS(b, treptr_nil))) :
               TREPTR_TRUTH(TRENUMBER_VAL(a) == TRENUMBER_VAL(b));
}

treptr
trenumber_builtin_number_equal (treptr x)
{
    TRELIST_DEFREGS();
	trearg_get2 (&car, &cdr, x);
    return trenumber_equal (car, cdr);
}

treptr
trenumber_lessp (treptr a, treptr b)
{
    return TREPTR_TRUTH(TRENUMBER_VAL(a) < TRENUMBER_VAL(b));
}

treptr
trenumber_builtin_lessp (treptr x)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args ("<", &car, &cdr, x);
    return trenumber_lessp (car, cdr);
}

treptr
trenumber_greaterp (treptr a, treptr b)
{
    return TREPTR_TRUTH(TRENUMBER_VAL(a) > TRENUMBER_VAL(b));
}

treptr
trenumber_builtin_greaterp (treptr x)
{
    TRELIST_DEFREGS();
    trenumber_builtin_args (">", &car, &cdr, x);
    return trenumber_greaterp (car, cdr);
}

treptr
trenumber_sqrt (treptr x)
{
    return treatom_number_get (sqrt (TRENUMBER_VAL(x)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_sqrt (treptr x)
{
    return trenumber_sqrt (trearg_get (x));
}

treptr
trenumber_sin (treptr x)
{
    return treatom_number_get (sin (TRENUMBER_VAL(x)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_sin (treptr x)
{
    return trenumber_sin (trearg_get (x));
}

treptr
trenumber_cos (treptr x)
{
    return treatom_number_get (cos (TRENUMBER_VAL(x)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_cos (treptr x)
{
    return trenumber_cos (trearg_get (x));
}

treptr
trenumber_atan (treptr x)
{
    return treatom_number_get (atan (TRENUMBER_VAL(x)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_atan (treptr x)
{
    return trenumber_atan (trearg_get (x));
}

treptr
trenumber_atan2 (treptr a, treptr b)
{
    return treatom_number_get (atan2 (TRENUMBER_VAL(a), TRENUMBER_VAL(b)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_atan2 (treptr x)
{
    treptr a;
    treptr b;
    trearg_get2 (&a, &b, x);
    return trenumber_atan2 (a, b);
}

treptr
trenumber_random ()
{
    return treatom_number_get ((float) random (), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_random (treptr dummy)
{
    (void) dummy;
    return trenumber_random ();
}

treptr
trenumber_exp (treptr x)
{
    return treatom_number_get (expf (TRENUMBER_VAL(trearg_get (x))), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_exp (treptr x)
{
    return trenumber_exp (trearg_get (x));
}

treptr
trenumber_pow (treptr a, treptr b)
{
    return treatom_number_get (pow (TRENUMBER_VAL(a), TRENUMBER_VAL(b)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_pow (treptr x)
{
    treptr a;
    treptr b;
    trearg_get2 (&a, &b, x);
    return trenumber_pow (a, b);
}

treptr
trenumber_round (treptr x)
{
    return treatom_number_get (round (TRENUMBER_VAL(x)), TRENUMTYPE_FLOAT);
}

treptr
trenumber_builtin_round (treptr x)
{
    return trenumber_round (trearg_get (x));
}
