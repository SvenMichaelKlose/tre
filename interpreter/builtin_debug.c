/*
 * tré – Copyright (c) 2005–2007,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include <stdlib.h>

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "error.h"
#include "debug.h"
#include "thread.h"
#include "stream.h"
#include "main.h"
#include "builtin_debug.h"
#include "argument.h"
#include "symtab.h"

treptr
tredebug_builtin_end_debug (treptr no_args)
{
    (void) no_args;

    tre_restart (NIL);

    /*NOTREACHED*/
    return NIL;
}

treptr
tredebug_builtin_invoke_debugger (treptr no_args)
{
    (void) no_args;

    printf ("INVOKE-DEBUGGER called.\n");
    tredebug_mode = TREDEBUGM_STEP;

    tredebug ();

    return NIL;
}

treptr
tredebug_breakpoint_arg (treptr args)
{
    return trearg_typed (1, TRETYPE_SYMBOL, trearg_get (args), "function name");
}

treptr
tredebug_builtin_set_breakpoint (treptr args)
{
    tredebug_set_breakpoint (SYMBOL_NAME(tredebug_breakpoint_arg (args)));
    return NIL;
}

treptr
tredebug_builtin_remove_breakpoint (treptr args)
{
    tredebug_remove_breakpoint (SYMBOL_NAME(tredebug_breakpoint_arg (args)));
    return NIL;
}

#endif /* #ifdef INTERPRETER */
