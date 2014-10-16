/*
 * tré – Copyright (c) 2005–2009,2012–2014 Sven Michael Klose <pixel@copei.de>
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
#include "symtab.h"
#include "symbol.h"

treptr treptr_macroexpand_hook;
treptr treptr_current_macro;

treptr
tremacro_builtin_macroexpand_1 (treptr list)
{
    treptr args = CONS(list, treptr_nil);
    treptr ret;

    tregc_push (args);
    ret = treeval_funcall (SYMBOL_FUNCTION(treptr_macroexpand_hook), args, FALSE);
    tregc_pop ();

    return ret;
}

treptr
tremacro_builtin_macroexpand (treptr list)
{
    treptr fun = SYMBOL_FUNCTION(treptr_macroexpand_hook);
    treptr n   = trearg_get (list);

    if (NOT(fun))
        return n;

    do {
		list = n;
		tregc_push (list);
        n = tremacro_builtin_macroexpand_1 (list);
		tregc_pop ();
    } while (!trelist_equal (list, n));

#ifdef TRE_PRINT_MACROEXPANSIONS
    treprint (n);
#endif

    return n;
}

void
tremacro_init (void)
{
    treptr_macroexpand_hook = symbol_get ("*MACROEXPAND-HOOK*");
    EXPAND_UNIVERSE(treptr_macroexpand_hook);

    treptr_current_macro = symbol_get ("*CURRENT-MACRO*");
    EXPAND_UNIVERSE(treptr_current_macro);
}

#endif /* #ifdef INTERPRETER */
