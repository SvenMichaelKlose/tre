/*
 * tré - Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
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

/*tredoc
  (cmd :name end-debug
	(descr "Leaves the debugger and terminated the current program.'))
 */
treptr
tredebug_builtin_end_debug (treptr no_args)
{
    struct tre_atom *atom;
    treptr   b;
    ulong  i;

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

/*tredoc
  (cmd :name invoke-debugger
	(descr "Invokes debugger."))
 */
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
    return trearg_typed (1, TRETYPE_VARIABLE, trearg_get (args), "function name");
}

/*tredoc
  (cmd :name set-breakpoint
	(arg :name function :type function
		 "Function to set breakpoint on function.")
	(descr
	  "Sets breakpoint. Before the breakpointed function is called, "
	  "the debugger is invoked."))
 */
treptr
tredebug_builtin_set_breakpoint (treptr args)
{
    tredebug_set_breakpoint (TREATOM_NAME(tredebug_breakpoint_arg (args)));
    return treptr_nil;
}

/*tredoc
  (cmd :name remove-breakpoint
	(desc "Removes formerly set breakpoint on function."))
 */
treptr
tredebug_builtin_remove_breakpoint (treptr args)
{
    tredebug_remove_breakpoint (TREATOM_NAME(tredebug_breakpoint_arg (args)));
    return treptr_nil;
}
