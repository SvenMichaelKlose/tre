/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Evaluation related section.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "gc.h"
#include "print.h"
#include "error.h"
#include "thread.h"
#include "debug.h"

lispptr lispptr_macroexpand_hook;
struct lisp_atom *lispatom_macroexpand_hook;

lispptr
lispmacro_builtin_macroexpand_1 (lispptr list)
{
    lispptr  args;
    lispptr  ret;
    lispptr  fake;

    if (lispatom_macroexpand_hook->fun == lispptr_nil)
        return list;

    args = CONS(list, lispptr_nil);
    lispgc_push (args);
    fake = CONS(lispptr_macroexpand_hook, args),
    lispgc_push (fake);
    ret = lispeval_funcall (lispatom_macroexpand_hook->fun, fake, FALSE);
    lispgc_pop ();
    lispgc_pop ();

    return ret;
}

/*
 * (MACRO-EXPAND form)
 *
 * Expand all macro calls in form.
 */
lispptr
lispmacro_builtin_macroexpand (lispptr list)
{   
    lispptr  n = list;

    if (lispatom_macroexpand_hook->fun == lispptr_nil)
        return list;

    do {
	list = n;
	lispgc_push (list);
        n = lispmacro_builtin_macroexpand_1 (list);
	lispgc_pop ();
    } while (!lisplist_equal (list, n));

    return n;
}            

void
lispmacro_init (void)
{
    lispptr_macroexpand_hook = lispatom_refget ("*MACROEXPAND-HOOK*",
                                                LISPCONTEXT_PACKAGE());
    lispatom_macroexpand_hook = LISPPTR_TO_ATOM(lispptr_macroexpand_hook);
}
