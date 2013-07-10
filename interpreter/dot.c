/*
 * tré – Copyright (c) 2008,2012–2013 Sven Michael Klose <pixel@copei.de>
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
#include "thread.h"
#include "apply.h"
#include "symbol.h"

treptr treptr_dotexpand_hook;

treptr
tredot_expand (treptr list)
{
    return TRESYMBOL_FUN(treptr_dotexpand_hook) == treptr_nil ?
               list :
               trefuncall (TRESYMBOL_FUN(treptr_dotexpand_hook), CONS(list, treptr_nil));
}

void
tredot_init (void)
{
    treptr_dotexpand_hook = treatom_get ("*DOTEXPAND-HOOK*", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_dotexpand_hook);
}

#endif /* #ifdef INTERPRETER */
