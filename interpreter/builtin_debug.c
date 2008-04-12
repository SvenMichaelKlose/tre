/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#include "config.h"
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
treptr
tredebug_builtin_end_debug (treptr no_args)
{
    struct tre_atom *atom;
    treptr   b;
    unsigned  i;

    (void) no_args;

    for (i = 0; i < NUM_ATOMS; i++) {
        atom = &tre_atoms[i];
		if (atom->type == TRETYPE_UNUSED)
	    	continue;
        b = atom->binding;
        if (b == treptr_nil)
	    	continue;

		while (CDR(b) != treptr_nil)
	    	b = CDR(b);

        atom->value = CAR(b);
		atom->binding = treptr_nil;
    }

    tre_restart (treptr_nil);

    /*NOTREACHED*/
    return treptr_nil;
}

treptr
tredebug_builtin_invoke_debugger (treptr no_args)
{
    (void) no_args;

    printf ("INVOKE-DEBUGGER called.\n");
    tredebug_mode = TREDEBUGM_STEP;

    tredebug ();

    return treptr_nil;
}

treptr
tredebug_breakpoint_arg (treptr args)
{
    return trearg_variable (1, "want 'FUNCTION-NAME", trearg_get (args));
}

treptr
tredebug_builtin_set_breakpoint (treptr args)
{
    tredebug_set_breakpoint (TREATOM_NAME(tredebug_breakpoint_arg (args)));
    return treptr_nil;
}

treptr
tredebug_builtin_remove_breakpoint (treptr args)
{
    tredebug_remove_breakpoint (TREATOM_NAME(tredebug_breakpoint_arg (args)));
    return treptr_nil;
}
