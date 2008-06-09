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

    if (TREPTR_IS_NUMBER(arg) == FALSE)
        return treptr_nil;
    return treptr_t;
}

/*
 * Expect and take single argument.
 *
 * Issues an error if the argument is not a number.
 */
treptr
trenumber_get_arg (treptr args)
{
	return trearg_number (1, NULL, trearg_get (args));
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

    if (TREPTR_IS_NUMBER(arg) && (TRENUMBER_TYPE(arg) == TRENUMTYPE_CHAR))
		return treptr_t;
    return treptr_nil;
}

/*
 * (CODE-CHAR integer)
 *
 * Returns the character corresponding to code 'integer'.
 */
treptr
trenumber_builtin_code_char (treptr args)
{
    treptr  arg = trenumber_get_arg (args);
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
    treptr  arg = trenumber_get_arg (args);
    int  tmp = (int) TRENUMBER_VAL(arg);

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

    trearg_get2 (&x, &y, args);
    int  ix = (int) TRENUMBER_VAL(x);
    int  iy = (int) TRENUMBER_VAL(y);

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

    trearg_get2 (&x, &y, args);
    int  ix = (int) TRENUMBER_VAL(x);
    int  iy = (int) TRENUMBER_VAL(y);

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

    trearg_get2 (&x, &y, args);
    unsigned long  ix = (unsigned long) TRENUMBER_VAL(x);
    unsigned long  iy = (unsigned long) TRENUMBER_VAL(y);

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

    trearg_get2 (&x, &y, args);
    unsigned long  ix = (unsigned long) TRENUMBER_VAL(x);
    unsigned long  iy = (unsigned long) TRENUMBER_VAL(y);

    return treatom_number_get ((double) (ix >> iy), TRENUMTYPE_INTEGER);
}
