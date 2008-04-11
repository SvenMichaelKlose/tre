/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Error handling.
 */

#include "config.h"
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
treerror_msg (treptr expr, const char *prefix, const char *msg, va_list ap)
{
    fflush (stdout);
    fprintf (stderr, "*** %s: ", prefix);
    vfprintf (stderr, msg, ap);
    fprintf (stderr, ".\n");

    if (expr != treptr_invalid) {
	fprintf (stderr, "Erroraneous object:\n");
        treprint (expr);
    }
    fflush (stderr);
}

void
treerror_internal (treptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    treerror_msg (expr, "INTERNAL INTERPRETER ERROR", msg, ap);

    (void) tredebug ();
    tre_exit (-1);
}

void
treerror_macroexpansion (void)
{
    treptr c = TREATOM_VALUE(treptr_current_macro);

    if (c == treptr_nil)
        return;

    fprintf (stderr, "During expansion of macro %s:\n", TREATOM_NAME(c));
}

treptr
treerror (treptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    treerror_macroexpansion ();
    treerror_msg (expr, "ERROR", msg, ap);

    return tredebug ();
}

void
treerror_norecover (treptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    treerror_macroexpansion ();
    treerror_msg (expr, "UNRECOVERABLE ERROR", msg, ap);

    tredebug ();
}

void
trewarn (treptr expr, const char *msg, ...)
{
    va_list ap;
    va_start(ap, msg);

    treerror_macroexpansion ();
    treerror_msg (expr, "WARNING", msg, ap);
}

/*
 * (ERROR string)
 *
 * Terminate current read-eval loop and issue an error.
 */
treptr
treerror_builtin_error (treptr args)
{
    treptr  arg = trearg_get (args);

    if (TREPTR_IS_STRING(arg) == FALSE)
        treerror (arg, "string expected");

    return treerror (treptr_invalid, TREATOM_STRINGP(arg));
}

char *
treerror_typestring (treptr x)
{
    switch (TREPTR_TYPE(x)) {
        case TRETYPE_STRING:
            return "string";

        case TRETYPE_ARRAY:
            return "array";

        case TRETYPE_NUMBER:
            return "number";

        case TRETYPE_CONS:
            return "cons";

        case TRETYPE_VARIABLE:
            return TREPTR_IS_SYMBOL(x) ? "symbol" : "variable";

        case TRETYPE_MACRO:
            return "macro";

        case TRETYPE_SPECIAL:
            return "special form";

        default:
            treerror_internal (x, "unkown atom");
            return NULL;
    }
}
