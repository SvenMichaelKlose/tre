/*
 * tré – Copyright (c) 2005–2007,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>
#include <stdarg.h>

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
#include "symbol.h"

void
treerror_msg (treptr expr, const char * prefix, const char * msg, va_list ap)
{
	trestream * s = treio_get_stream ();

    fflush (stdout);
	if (treio_readerstreamptr)
		fprintf (stderr, "; Break on line %ld, column %ld in file '%s'.\n", (long) s->line, (long) s->column, s->file_name);
    fprintf (stderr, "; %s: ", prefix);
    vfprintf (stderr, msg, ap);
    fprintf (stderr, "\n");

    if (expr != treptr_invalid) {
		fprintf (stderr, "; Misplaced object:\n");
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
    treptr c = TRESYMBOL_VALUE(treptr_current_macro);

    if (NOT(c))
        return;

    fprintf (stderr, "; During expansion of macro %s:\n", TRESYMBOL_NAME(c));
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
treerror_typename (size_t t)
{
	/* !!! Keep this in sync with type.h! */
	static const char * type_names[] = {
		"cons",
		"symbol",
		"number",
		"string",
		"array",
		"built-in function",
		"built-in special form",
		"macro",
		"function",
		"special form",
		"atom"
	};

	if (t > TRETYPE_ATOM)
		treerror_internal (t, "Unknown type index %u.", t);

	return type_names[t];
}
