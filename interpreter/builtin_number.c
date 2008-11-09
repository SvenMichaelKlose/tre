/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Number atom related section.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "argument.h"

#include <ctype.h>

/*
 * (NUMBERP obj)
 *
 * Returns T if the argument is a number. NIL otherwise.
 */
treptr
trenumber_builtin_numberp (treptr list)
{
    treptr  arg = trearg_get (list);

    return TREPTR_TRUTH(TREPTR_IS_NUMBER(arg));
}

/*
 * Expect and take single argument.
 *
 * Issues an error if the argument is not a number.
 */
treptr
trenumber_arg_get (treptr args)
{
	return trearg_typed (1, TRETYPE_NUMBER, trearg_get (args), NULL);
}

/*
 * Expect and take two arguments.
 *
 * Issues an error if an argument is not a number.
 */
void
trenumber_arg_get2 (treptr * first, treptr * second, treptr args)
{
	trearg_get2 (first, second, args);
	*first = trearg_typed (1, TRETYPE_NUMBER, *first, NULL);
	*second = trearg_typed (2, TRETYPE_NUMBER, *second, NULL);
}

/*
 * (CHARACTERP obj)
 *
 * Returns the character corresponding to code 'integer'.
 */
treptr
trenumber_builtin_characterp (treptr args)
{
    treptr  arg = trearg_get (args);

    return TREPTR_TRUTH(TREPTR_IS_NUMBER(arg) && (TRENUMBER_TYPE(arg) == TRENUMTYPE_CHAR));
}

/*
 * (CODE-CHAR integer)
 *
 * Returns the character corresponding to code 'integer'.
 */
treptr
trenumber_builtin_code_char (treptr args)
{
    treptr  arg = trenumber_arg_get (args);
    char tmp;

    tmp = (char) TRENUMBER_VAL(arg);
    return treatom_number_get ((double) tmp, TRENUMTYPE_CHAR);
}

/*
 * (INTEGER number)
 *
 * Returns 'number' converted to integer or the original 'number'.
 */
treptr
trenumber_builtin_integer (treptr args)
{
    treptr  arg = trenumber_arg_get (args);
    long  tmp = (long) TRENUMBER_VAL(arg);

    return treatom_number_get ((double) tmp, TRENUMTYPE_INTEGER);
}

/*
 * (BIT-OR number number)
 */
treptr
trenumber_builtin_bit_or (treptr args)
{
	treptr x;
	treptr y;

    trenumber_arg_get2 (&x, &y, args);
    long  ix = (long) TRENUMBER_VAL(x);
    long  iy = (long) TRENUMBER_VAL(y);

    return treatom_number_get ((double) (ix | iy), TRENUMTYPE_INTEGER);
}

/*
 * (BIT-AND number number)
 */
treptr
trenumber_builtin_bit_and (treptr args)
{
	treptr x;
	treptr y;

    trenumber_arg_get2 (&x, &y, args);
    long  ix = (long) TRENUMBER_VAL(x);
    long  iy = (long) TRENUMBER_VAL(y);

    return treatom_number_get ((double) (ix & iy), TRENUMTYPE_INTEGER);
}

/*
 * (<< number bits)
 */
treptr
trenumber_builtin_bit_shift_left (treptr args)
{
	treptr x;
	treptr y;

    trenumber_arg_get2 (&x, &y, args);
    ulong  ix = (ulong) TRENUMBER_VAL(x);
    ulong  iy = (ulong) TRENUMBER_VAL(y);

    return treatom_number_get ((double) (ix << iy), TRENUMTYPE_INTEGER);
}

/*
 * (>> number bits)
 */
treptr
trenumber_builtin_bit_shift_right (treptr args)
{
	treptr x;
	treptr y;

    trenumber_arg_get2 (&x, &y, args);
    ulong  ix = (ulong) TRENUMBER_VAL(x);
    ulong  iy = (ulong) TRENUMBER_VAL(y);

    return treatom_number_get ((double) (ix >> iy), TRENUMTYPE_INTEGER);
}
