/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>
#include <stdarg.h>

#include "atom.h"
#include "list.h"
#include "argument.h"
#include "error.h"
#include "string2.h"
#include "builtin_error.h"

treptr
treerror_builtin_error (treptr args)
{
    treptr  arg = trearg_get (args);

    if (TREPTR_IS_STRING(arg) == FALSE)
        treerror (arg, "string expected");

    return treerror (treptr_invalid, TREPTR_STRINGZ(arg));
}
