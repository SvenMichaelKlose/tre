/*
 * TRE interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Built-in error function.
 */

#include "atom.h"
#include "list.h"
#include "argument.h"
#include "error.h"
#include "string2.h"
#include "builtin_error.h"

#include <stdio.h>
#include <stdarg.h>

/*tredoc
 (cmd :name %ERROR
   (descr "Terminate current read-eval loop and issue an error."))
 */
treptr
treerror_builtin_error (treptr args)
{
    treptr  arg = trearg_get (args);

    if (TREPTR_IS_STRING(arg) == FALSE)
        treerror (arg, "string expected");

    return treerror (treptr_invalid, TREATOM_STRINGP(arg));
}
