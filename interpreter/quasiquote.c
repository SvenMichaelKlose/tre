/*
 * tré – Copyright (c) 2008,2012–2014 Sven Michael Klose <pixel@copei.de>
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
#include "funcall.h"
#include "symtab.h"
#include "symbol.h"

treptr treptr_quasiquoteexpand_hook;

treptr
trequasiquote_expand (treptr list)
{
    treptr sym = SYMBOL_VALUE(treptr_quasiquoteexpand_hook);
    return NOT(sym) ?
               list :
               funcall (sym, CONS(list, NIL));
}

void
trequasiquote_init (void)
{
    treptr_quasiquoteexpand_hook = symbol_get ("*QUASIQUOTEEXPAND-HOOK*");
    EXPAND_UNIVERSE(treptr_quasiquoteexpand_hook);
}

#endif /* #ifdef INTERPRETER */
