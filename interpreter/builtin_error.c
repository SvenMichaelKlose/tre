/*
 * tré – Copyright (c) 2005–2008,2013–2014 Sven Michael Klose <pixel@copei.de>
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
treerror_error (treptr message)
{
    return STRINGP(message) == FALSE ?
               treerror (message, "String expected.") :
               treerror (treptr_invalid, TREPTR_STRINGZ(message));
}

treptr
treerror_builtin_error (treptr x)
{
    return treerror_error (trearg_get (x));
}
