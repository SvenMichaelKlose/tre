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

treptr treptr_quasiquoteexpand_hook;

treptr
trequasiquote_expand (treptr list)
{
    treptr sym = TRESYMBOL_FUN(treptr_quasiquoteexpand_hook);
    return NOT(sym) ?
               list :
               trefuncall (sym, CONS(list, treptr_nil));
}

void
trequasiquote_init (void)
{
    treptr_quasiquoteexpand_hook = treatom_get ("*QUASIQUOTEEXPAND-HOOK*", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_quasiquoteexpand_hook);
}

#endif /* #ifdef INTERPRETER */
