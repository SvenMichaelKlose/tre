/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "error.h"
#include "debug.h"
#include "thread.h"
#include "io.h"
#include "main.h"
#include "builtin_debug.h"
#include "argument.h"

/*
 * Return to top-level.
 *
 * Removes all argument bindings.
 */
lispptr
lispdebug_builtin_end_debug (lispptr no_args)
{
    struct lisp_atom *atom;
    lispptr   b;
    unsigned  i;

    (void) no_args;

    for (i = 0; i < NUM_ATOMS; i++) {
        atom = &lisp_atoms[i];
	if (atom->type == ATOM_UNUSED)
	    continue;
        b = atom->binding;
        if (b == lispptr_nil)
	    continue;

	while (CDR(b) != lispptr_nil)
	    b = CDR(b);

        atom->value = CAR(b);
	atom->binding = lispptr_nil;
    }

    lisp_restart ();

    /*NOTREACHED*/
    return lispptr_nil;
}

lispptr
lispdebug_builtin_invoke_debugger (lispptr no_args)
{
    (void) no_args;

    lispdebug_mode = LISPDEBUGM_STEP;

    lispdebug ();

    return lispptr_nil;
}

lispptr
lispdebug_builtin_set_breakpoint (lispptr name)
{
    lispptr  n = lisparg_get (name);

    if (!LISPPTR_IS_VARIABLE(n))
	return lisperror (n, "variable expected");

    lispdebug_set_breakpoint (LISPATOM_NAME(n));

    return lispptr_nil;
}

lispptr
lispdebug_builtin_remove_breakpoint (lispptr name)
{
    lispptr  n = lisparg_get (name);

    if (!LISPPTR_IS_VARIABLE(n))
	return lisperror (n, "variable expected");

    lispdebug_remove_breakpoint (LISPATOM_NAME(n));

    return lispptr_nil;
}
