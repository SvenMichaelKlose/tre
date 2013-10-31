/*
 * tré – Copyright (c) 2005–2009,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include <stdlib.h>

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "eval.h"
#include "gc.h"
#include "print.h"
#include "error.h"
#include "thread.h"
#include "debug.h"
#include "argument.h"
#include "symbol.h"

treptr treptr_macroexpand_hook;
treptr treptr_current_macro;

treptr
tremacro_builtin_macroexpand_1 (treptr list)
{
    return treeval_funcall (TRESYMBOL_FUN(treptr_macroexpand_hook), CONS(list, treptr_nil), FALSE);
}

treptr
tremacro_builtin_macroexpand (treptr list)
{
    treptr fun = TRESYMBOL_FUN(treptr_macroexpand_hook);
    treptr n   = CONS(trearg_get (list), treptr_nil);

    if (fun == treptr_nil)
        return CAR(n);

    do {
		list = n;
		tregc_push (list);
        n = tremacro_builtin_macroexpand_1 (list);
		tregc_pop ();
    } while (!trelist_equal (list, n));

#ifdef TRE_PRINT_MACROEXPANSIONS
    treprint (CAR(m));
#endif

    return CAR(n);
}

void
tremacro_init (void)
{
    treptr_macroexpand_hook = treatom_get ("*MACROEXPAND-HOOK*", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_macroexpand_hook);

    treptr_current_macro = treatom_get ("*CURRENT-MACRO*", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_current_macro);
}

#endif /* #ifdef INTERPRETER */
