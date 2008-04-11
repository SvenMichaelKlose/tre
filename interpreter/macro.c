/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Evaluation related section.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "gc.h"
#include "print.h"
#include "error.h"
#include "thread.h"
#include "debug.h"

treptr treptr_macroexpand_hook;
struct tre_atom *treatom_macroexpand_hook;

treptr treptr_current_macro;

treptr
tremacro_builtin_macroexpand_1 (treptr list)
{
    treptr  ret;
    treptr  fake;

    if (treatom_macroexpand_hook->fun == treptr_nil)
        return list;

    fake = CONS(treptr_macroexpand_hook, CONS(list, treptr_nil));
    tregc_push (fake);
    ret = treeval_funcall (treatom_macroexpand_hook->fun, fake, FALSE);
    tregc_pop ();

    return ret;
}

/*
 * (MACRO-EXPAND form)
 *
 * Expand macros in form until it doesn't change anymore.
 */
treptr
tremacro_builtin_macroexpand (treptr list)
{   
    treptr  n = list;

    if (treatom_macroexpand_hook->fun == treptr_nil)
        return list;

    do {
		list = n;
		tregc_push (list);
        n = tremacro_builtin_macroexpand_1 (list);
		tregc_pop ();
    } while (!trelist_equal (list, n));

    return n;
}            

void
tremacro_init (void)
{
    treptr_macroexpand_hook = treatom_get ("*MACROEXPAND-HOOK*", TRECONTEXT_PACKAGE());
    treatom_macroexpand_hook = & TREPTR_TO_ATOM(treptr_macroexpand_hook);
    EXPAND_UNIVERSE(treptr_macroexpand_hook);

    treptr_current_macro = treatom_get ("*CURRENT-MACRO*", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_current_macro);
}
