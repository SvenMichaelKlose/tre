/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Number atom related section.
 */

#include "lisp.h"
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
lispptr
lispnumber_builtin_numberp (lispptr list)
{
    lispptr  arg = lisparg_get (list);

    if (LISPPTR_IS_NUMBER(arg) == FALSE)
        return lispptr_nil;
    return lispptr_t;
}

/*
 * Expect and take single argument.
 *
 * Issues an error if the argument is not a number.
 */
lispptr
lispnumber_get_arg (lispptr args)
{
    lispptr  arg = lisparg_get (args);

    if (LISPPTR_IS_NUMBER(arg) == FALSE)
	return lisperror (arg, "number expected");

    return arg;
}

/*
 * (CHARACTERP obj)
 *
 * Returns the character corresponding to code 'integer'.
 */
lispptr
lispnumber_builtin_characterp (lispptr args)
{
    lispptr  arg = lisparg_get (args);

    if (LISPPTR_IS_NUMBER(arg) && (LISPNUMBER_TYPE(arg) == LISPNUMTYPE_CHAR))
	return lispptr_t;

    return lispptr_nil;
}

/*
 * (CODE-CHAR integer)
 *
 * Returns the character corresponding to code 'integer'.
 */
lispptr
lispnumber_builtin_code_char (lispptr args)
{
    lispptr  arg = lispnumber_get_arg (args);
    char tmp;

    tmp = (char) LISPNUMBER_VAL(arg);
    return lispatom_number_get ((float) tmp, LISPNUMTYPE_CHAR);
}

/*
 * (INTEGER number)
 *
 * Returns 'number' converted to integer or the original 'number'.
 */
lispptr
lispnumber_builtin_integer (lispptr args)
{
    lispptr  arg = lispnumber_get_arg (args);
    int  tmp = (int) LISPNUMBER_VAL(arg);

    return lispatom_number_get ((float) tmp, LISPNUMTYPE_INTEGER);
}
