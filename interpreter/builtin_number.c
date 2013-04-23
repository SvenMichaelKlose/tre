/*
 * tré – Copyright (c) 2005–2010,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <ctype.h>

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "argument.h"

treptr
trenumber_builtin_numberp (treptr list)
{
    treptr  arg = trearg_get (list);

    return TREPTR_TRUTH(TREPTR_IS_NUMBER(arg));
}

treptr
trenumber_arg_get (treptr args)
{
	return trearg_typed (1, TRETYPE_NUMBER, trearg_get (args), NULL);
}

void
trenumber_arg_get2 (treptr * first, treptr * second, treptr args)
{
	trearg_get2 (first, second, args);
	*first = trearg_typed (1, TRETYPE_NUMBER, *first, NULL);
	*second = trearg_typed (2, TRETYPE_NUMBER, *second, NULL);
}

treptr
trenumber_builtin_characterp (treptr args)
{
    treptr  arg = trearg_get (args);

    return TREPTR_TRUTH(TREPTR_IS_NUMBER(arg) && (TRENUMBER_TYPE(arg) == TRENUMTYPE_CHAR));
}

treptr
trenumber_code_char (treptr x)
{
    char	tmp;

    tmp = (char) TRENUMBER_VAL(x);
    return treatom_number_get ((double) tmp, TRENUMTYPE_CHAR);
}

treptr
trenumber_builtin_code_char (treptr args)
{
    return trenumber_code_char (trenumber_arg_get (args));
}

treptr
trenumber_builtin_integer (treptr args)
{
    treptr  arg = trenumber_arg_get (args);
    long    tmp = (long) TRENUMBER_VAL(arg);

    return treatom_number_get ((double) tmp, TRENUMTYPE_INTEGER);
}

treptr
trenumber_builtin_float (treptr args)
{
    treptr  arg = trenumber_arg_get (args);

    return treatom_number_get (TRENUMBER_VAL(arg), TRENUMTYPE_FLOAT);
}

void
trenumber_arg_bit_op (size_t * ix, size_t * iy, treptr args)
{
	treptr  x;
	treptr  y;

    trenumber_arg_get2 (&x, &y, args);
    *ix = (size_t) TRENUMBER_VAL(x);
	*iy = (size_t) TRENUMBER_VAL(y);
}

#define TRENUMBER_DEF_BITOP(name, op) \
	treptr	\
	name (treptr args)	\
	{	\
		size_t	ix;	\
		size_t	iy;	\
	\
    	trenumber_arg_bit_op (&ix, &iy, args);	\
    	return treatom_number_get ((double) (ix op iy),	\
								   TRENUMTYPE_INTEGER);	\
	}

TRENUMBER_DEF_BITOP(trenumber_builtin_bit_or, |);
TRENUMBER_DEF_BITOP(trenumber_builtin_bit_and, &);
TRENUMBER_DEF_BITOP(trenumber_builtin_bit_shift_left, <<);
TRENUMBER_DEF_BITOP(trenumber_builtin_bit_shift_right, >>);
