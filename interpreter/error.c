/*
 * tré – Copyright (c) 2005–2007,2011–2012 Sven Michael Klose <pixel@copei.de>
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
#include "string2.h"
#include "macro.h"
#include "xxx.h"

#include <stdio.h>
#include <stdarg.h>

void
treerror_msg (treptr expr, const char *prefix, const char *msg, va_list ap)
{
	struct tre_stream * s = treio_get_stream ();

    fflush (stdout);
    fprintf (stderr, "; In interpreter:\n; %s: ", prefix);
    vfprintf (stderr, msg, ap);
    fprintf (stderr, ".\n");

	if (treio_readerstreamptr)
		fprintf (stderr, "; In %s, line %ld, column %ld.\n", s->file_name, s->line, s->column);

    if (expr != treptr_invalid) {
		fprintf (stderr, "; Erroraneous object:\n");
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

	CRASH();
}

void
treerror_macroexpansion (void)
{
    treptr c = TREATOM_VALUE(treptr_current_macro);

    if (c == treptr_nil)
        return;

    fprintf (stderr, "; During expansion of macro %s:\n", TREATOM_NAME(c));
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

    tredebug ();
}

const char *
treerror_typename (ulong t)
{
	/* !!! Keep this in sync with type.h! */
	static const char * type_names[] = {
		"cons",
		"variable",
		"number",
		"string",
		"array",
		"built-in function",
		"built-in special form",
		"macro",
		"function",
		"special form",
		"package",
		"atom"
	};

	if (t > TRETYPE_ATOM)
		treerror_internal (t, "unknown type index %u", t);

	return type_names[t];
}
