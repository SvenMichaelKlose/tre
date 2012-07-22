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

treptr treptr_dotexpand_hook;
struct tre_atom *treatom_dotexpand_hook;

treptr
tredot_expand (treptr list)
{
    treptr  ret;
    treptr  fake;

    if (treatom_dotexpand_hook->fun == treptr_nil)
        return list;

    fake = CONS(treptr_dotexpand_hook, CONS(list, treptr_nil));
    tregc_push (fake);
    ret = treeval_funcall (treatom_dotexpand_hook->fun, fake, FALSE);
	tregc_retval (ret);
    tregc_pop ();

    return ret;
}

void
tredot_init (void)
{
    treptr_dotexpand_hook =
        treatom_get ("*DOTEXPAND-HOOK*", TRECONTEXT_PACKAGE());
    treatom_dotexpand_hook = & TREPTR_TO_ATOM(treptr_dotexpand_hook);
    EXPAND_UNIVERSE(treptr_dotexpand_hook);
}

#endif /* #ifdef INTERPRETER */
