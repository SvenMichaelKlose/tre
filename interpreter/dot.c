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

treptr treptr_dotexpand_hook;

treptr
tredot_expand (treptr list)
{
    return NOT(SYMBOL_FUNCTION(treptr_dotexpand_hook)) ?
               list :
               funcall (SYMBOL_FUNCTION(treptr_dotexpand_hook), CONS(list, treptr_nil));
}

void
tredot_init (void)
{
    treptr_dotexpand_hook = symbol_get ("*DOTEXPAND-HOOK*");
    EXPAND_UNIVERSE(treptr_dotexpand_hook);
}

#endif /* #ifdef INTERPRETER */
