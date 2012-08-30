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

#include "builtin_apply.h"

treptr treptr_dotexpand_hook;
struct tre_atom *treatom_dotexpand_hook;

treptr
tredot_expand (treptr list)
{
    treptr  ret;

    if (treatom_dotexpand_hook->fun == treptr_nil)
        return list;

    ret = trebuiltin_funcall0 (treatom_dotexpand_hook->fun, CONS(list, treptr_nil));
	tregc_retval (ret);
    return ret;
}

void
tredot_init (void)
{
    treptr_dotexpand_hook = treatom_get ("*DOTEXPAND-HOOK*", TRECONTEXT_PACKAGE());
    treatom_dotexpand_hook = & TREPTR_TO_ATOM(treptr_dotexpand_hook);
    EXPAND_UNIVERSE(treptr_dotexpand_hook);
}

#endif /* #ifdef INTERPRETER */
