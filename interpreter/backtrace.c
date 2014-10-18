/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "xxx.h"
#include "ptr.h"
#include "cons.h"
#include "atom.h"
#include "symtab.h"
#include "symbol.h"
#include "backtrace.h"

treptr treptr_backtrace = 0;

#define TRE_BACKTRACE_FILTER(x) \
    (SPECIALP(_CAR(x)) || (NOT_NIL(_CDR(x)) && _CAR(x) == _CAR(_CDR(x))))

treptr
trebacktrace_r (treptr x)
{
    RETURN_NIL(x);
    if (TRE_BACKTRACE_FILTER(x))
        return trebacktrace_r (_CDR(x));
    return CONS(_CAR(x), trebacktrace_r (_CDR(x)));
}

treptr
trebacktrace ()
{
    return trebacktrace_r (SYMBOL_VALUE(treptr_backtrace));
}

void
trebacktrace_init ()
{
    treptr_backtrace = symbol_get ("*BACKTRACE*");
    SYMBOL_VALUE(treptr_backtrace) = treptr_nil;
}

void
trebacktrace_push (treptr x)
{
    (void) x;
#ifndef TRE_NO_BACKTRACE
    SYMBOL_VALUE(treptr_backtrace) = CONS(x, SYMBOL_VALUE(treptr_backtrace));
#endif
}

void
trebacktrace_pop ()
{
#ifndef TRE_NO_BACKTRACE
    treptr ancestors = _CDR(SYMBOL_VALUE(treptr_backtrace));
    cons_free (SYMBOL_VALUE(treptr_backtrace));
    SYMBOL_VALUE(treptr_backtrace) = ancestors;
#endif
}
