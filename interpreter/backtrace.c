/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "xxx.h"
#include "ptr.h"
#include "cons.h"
#include "atom.h"
#include "symbol.h"
#include "thread.h"

treptr treptr_backtrace;

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
    return trebacktrace_r (TRESYMBOL_VALUE(treptr_backtrace));
}

void
trebacktrace_init ()
{
    treptr_backtrace = treatom_get ("*BACKTRACE*", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_backtrace);
    TRESYMBOL_VALUE(treptr_backtrace) = treptr_nil;
}

void
trebacktrace_push (treptr x)
{
    TRESYMBOL_VALUE(treptr_backtrace) = CONS(x, TRESYMBOL_VALUE(treptr_backtrace));
}

void
trebacktrace_pop ()
{
    treptr ancestors = _CDR(TRESYMBOL_VALUE(treptr_backtrace));
    trelist_free (TRESYMBOL_VALUE(treptr_backtrace));
    TRESYMBOL_VALUE(treptr_backtrace) = ancestors;
}
