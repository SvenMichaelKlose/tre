/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Threading
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "thread.h"

/* Single-thread context. */
struct lisp_thread_context lisp_context;

void
lispthread_make ()
{
    LISPCONTEXT_ENV_CURRENT() = lispptr_nil;
    LISPCONTEXT_FUNSTACK() = lispptr_nil;
    LISPCONTEXT_PACKAGE() = lispptr_nil;
}

/* Add body to function stack. */
void
lispthread_push_call (lispptr list)
{
    LISPCONTEXT_FUNSTACK() = CONS(list, LISPCONTEXT_FUNSTACK());
}

/* Destructive pop from function stack. */
void
lispthread_pop_call ()
{
    lispptr tmp;

    tmp = LISPCONTEXT_FUNSTACK();
    LISPCONTEXT_FUNSTACK() = CDR(LISPCONTEXT_FUNSTACK());
    LISPLIST_FREE_EARLY(tmp);
}
