/*
 * tré – Copyright (c) 2005–2010,2012–2014 Sven Michael Klose <pixel@copei.de>
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
#include "symtab.h"
#include "builtin.h"
#include "builtin_number.h"
#include "builtin_string.h"
#include "assert.h"

treptr treptr_number_zero;
treptr treptr_number_one;

treptr
treeval_exprop (treptr x, treeval_opfunc_t func, const char * descr)
{
    treptr  arg;
    double  val;
	long    n = 1;

    arg = CAR(x);
    if (NUMBERP(arg) == FALSE)
        return treerror (arg, "Not a number.");
    val = TRENUMBER_VAL(arg);

	n = 2;
    x = CDR(x);
    while (NOT_NIL(x)) {
        arg = trearg_typed (n++, TRETYPE_NUMBER, CAR(x), descr);
        val = (*func) (val, TRENUMBER_VAL(arg));
        x = CDR(x);
    }

    return number_get_float (val);
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
		       treptr_number_zero :
               treeval_exprop (x, treeval_op_plus, "+");
}

treptr
trenumber_plus (treptr a, treptr b)
{
    ASSERT_NUMBER(a);
    ASSERT_NUMBER(b);
    return number_get_float (TRENUMBER_VAL(a) + TRENUMBER_VAL(b));
}

treptr
trenumber_builtin_character_plus (treptr x)
{
    return trenumber_code_char (trenumber_builtin_plus (x));
}

treptr
trenumber_difference (treptr a, treptr b)
{
    ASSERT_NUMBER(a);
    ASSERT_NUMBER(b);
    return number_get_float (TRENUMBER_VAL(a) - TRENUMBER_VAL(b));
}

treptr
trenumber_builtin_difference (treptr x)
{
    if (NOT(x))
		return treerror (treptr_nil, "Argument expected.");
    if (NOT(CDR(x)))
		return number_get_float (-TRENUMBER_VAL(CAR(x)));

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
		       treptr_number_one :
               treeval_exprop (x, treeval_op_times, "*");
}

treptr
trenumber_builtin_quotient (treptr x)
{
    if (NOT(x))
		return treerror (treptr_nil, "Argument expected.");
    if (NOT(CDR(x)))
		return number_get_float (1.0 / SYMBOL_VALUE(CAR(x)));

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
    ASSERT_NUMBER(x);
    ASSERT_NUMBER(mod);
    return number_get_float (fmod (TRENUMBER_VAL(x), TRENUMBER_VAL(mod)));
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
		       treptr_number_zero :
               treeval_exprop (x, treeval_op_logxor, "LOGXOR");
}

treptr
trenumber_equal (treptr a, treptr b)
{
    return STRINGP(a) || STRINGP(b) ?
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
    ASSERT_NUMBER(a);
    ASSERT_NUMBER(b);
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
    ASSERT_NUMBER(a);
    ASSERT_NUMBER(b);
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
    ASSERT_NUMBER(x);
    return number_get_float (sqrt (TRENUMBER_VAL(x)));
}

treptr
trenumber_builtin_sqrt (treptr x)
{
    return trenumber_sqrt (trearg_get (x));
}

treptr
trenumber_sin (treptr x)
{
    ASSERT_NUMBER(x);
    return number_get_float (sin (TRENUMBER_VAL(x)));
}

treptr
trenumber_builtin_sin (treptr x)
{
    return trenumber_sin (trearg_get (x));
}

treptr
trenumber_cos (treptr x)
{
    ASSERT_NUMBER(x);
    return number_get_float (cos (TRENUMBER_VAL(x)));
}

treptr
trenumber_builtin_cos (treptr x)
{
    return trenumber_cos (trearg_get (x));
}

treptr
trenumber_atan (treptr x)
{
    ASSERT_NUMBER(x);
    return number_get_float (atan (TRENUMBER_VAL(x)));
}

treptr
trenumber_builtin_atan (treptr x)
{
    return trenumber_atan (trearg_get (x));
}

treptr
trenumber_atan2 (treptr a, treptr b)
{
    ASSERT_NUMBER(a);
    ASSERT_NUMBER(b);
    return number_get_float (atan2 (TRENUMBER_VAL(a), TRENUMBER_VAL(b)));
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
    return number_get_float ((float) random ());
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
    ASSERT_NUMBER(x);
    return number_get_float (expf (TRENUMBER_VAL(x)));
}

treptr
trenumber_builtin_exp (treptr x)
{
    return trenumber_exp (trearg_get (x));
}

treptr
trenumber_pow (treptr a, treptr b)
{
    ASSERT_NUMBER(a);
    ASSERT_NUMBER(b);
    return number_get_float (pow (TRENUMBER_VAL(a), TRENUMBER_VAL(b)));
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
    ASSERT_NUMBER(x);
    return number_get_float (round (TRENUMBER_VAL(x)));
}

treptr
trenumber_builtin_round (treptr x)
{
    return trenumber_round (trearg_get (x));
}

treptr
trenumber_floor (treptr x)
{
    ASSERT_NUMBER(x);
    return number_get_float (floor (TRENUMBER_VAL(x)));
}

treptr
trenumber_builtin_floor (treptr x)
{
    return trenumber_floor (trearg_get (x));
}

void
trebuiltin_arith_init ()
{
    treptr_number_zero = number_get_float (0);
    treptr_number_one = number_get_float (1);
}
