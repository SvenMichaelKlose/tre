/*
 * tré – Copyright (c) 2005–2010,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <ctype.h>
#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "gc.h"
#include "argument.h"

treptr
trenumber_numberp (treptr object)
{
    return TREPTR_TRUTH(NUMBERP(object));
}

treptr
trenumber_characterp (treptr object)
{
    return TREPTR_TRUTH(NUMBERP(object) && (TRENUMBER_TYPE(object) == TRENUMTYPE_CHAR));
}

treptr
trenumber_code_char (treptr number)
{
    char tmp = (char) TRENUMBER_VAL(number);
    return number_get_char ((double) tmp);
}

TRENUMBER_DEF_BITOP(trenumber_builtin_bit_or, |);
TRENUMBER_DEF_BITOP(trenumber_builtin_bit_and, &);
TRENUMBER_DEF_BITOP(trenumber_builtin_bit_shift_left, <<);
TRENUMBER_DEF_BITOP(trenumber_builtin_bit_shift_right, >>);
