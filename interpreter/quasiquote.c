/*
 * tré – Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include "atom.h"
#include "list.h"
#include "eval.h"
#include "gc.h"
#include "print.h"
#include "thread.h"

treptr treptr_quasiquoteexpand_hook;
struct tre_atom *treatom_quasiquoteexpand_hook;

treptr
trequasiquote_expand (treptr list)
{
    treptr  ret;
    treptr  fake;

    if (treatom_quasiquoteexpand_hook->fun == treptr_nil)
        return list;

    fake = CONS(treptr_quasiquoteexpand_hook, CONS(list, treptr_nil));
    tregc_push (fake);
    ret = treeval_funcall (treatom_quasiquoteexpand_hook->fun, fake, FALSE);
	tregc_retval (ret);
    tregc_pop ();

    return ret;
}

void
trequasiquote_init (void)
{
    treptr_quasiquoteexpand_hook =
        treatom_get ("*QUASIQUOTEEXPAND-HOOK*", TRECONTEXT_PACKAGE());
    treatom_quasiquoteexpand_hook = & TREPTR_TO_ATOM(treptr_quasiquoteexpand_hook);
    EXPAND_UNIVERSE(treptr_quasiquoteexpand_hook);
}

#endif /* #ifdef INTERPRETER */
