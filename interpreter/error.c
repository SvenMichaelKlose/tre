/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Error handling.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "io.h"
#include "main.h"
#include "error.h"
#include "eval.h"
#include "print.h"
#include "debug.h"
#include "thread.h"
#include "argument.h"
#include "string.h"
#include "macro.h"

#include <stdio.h>
#include <stdarg.h>

void
lisperror_msg (lispptr expr, const char *prefix, const char *msg, va_list ap)
{
    fflush (stdout);
    fprintf (stderr, "*** %s: ", prefix);
    vfprintf (stderr, msg, ap);
    fprintf (stderr, ".\n");

    if (expr != lispptr_invalid) {
	fprintf (stderr, "Erroraneous object:\n");
        lispprint (expr);
    }
    fflush (stderr);
}

void
lisperror_internal (lispptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    lisperror_msg (expr, "INTERNAL INTERPRETER ERROR", msg, ap);

    (void) lispdebug ();
    lisp_exit (-1);
}

void
lisperror_macroexpansion (void)
{
    lispptr c = LISPATOM_VALUE(lispptr_current_macro);

    if (c == lispptr_nil)
        return;

    fprintf (stderr, "During expansion of macro %s:\n", LISPATOM_NAME(c));
}

lispptr
lisperror (lispptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    lisperror_macroexpansion ();
    lisperror_msg (expr, "ERROR", msg, ap);

    return lispdebug ();
}

void
lisperror_norecover (lispptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    lisperror_macroexpansion ();
    lisperror_msg (expr, "UNRECOVERABLE ERROR", msg, ap);

    lispdebug ();
}

void
lispwarn (lispptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    lisperror_macroexpansion ();
    lisperror_msg (expr, "WARNING", msg, ap);
}

/*
 * (ERROR string)
 *
 * Terminate current read-eval loop and issue an error.
 */
lispptr
lisperror_builtin_error (lispptr args)
{
    lispptr  arg = lisparg_get (args);

    if (LISPPTR_IS_STRING(arg) == FALSE)
        lisperror (arg, "string expected");

    return lisperror (lispptr_invalid, LISPATOM_STRINGP(arg));
}

char *
lisperror_typestring (lispptr x)
{
    switch (LISPPTR_TYPE(x)) {
        case ATOM_STRING:
            return "string";

        case ATOM_ARRAY:
            return "array";

        case ATOM_NUMBER:
            return "number";

        case ATOM_EXPR:
            return "cons";

        case ATOM_VARIABLE:
            return LISPPTR_IS_SYMBOL(x) ? "symbol" : "variable";

        case ATOM_MACRO:
            return "macro";

        case ATOM_SPECIAL:
            return "special form";

        default:
            lisperror_internal (x, "unkown atom");
            return NULL;
    }
}
