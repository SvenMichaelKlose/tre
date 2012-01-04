/*
 * tré - Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 */

/*
 * NOTE: There's only a single thread.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "thread.h"

struct tre_thread_context tre_context;

void
trethread_make ()
{
    TRECONTEXT_ENV_CURRENT() = treptr_nil;
    TRECONTEXT_FUNSTACK() = treptr_nil;
    TRECONTEXT_PACKAGE() = treptr_nil;
}

void
trethread_push_call (treptr list)
{
    TRECONTEXT_FUNSTACK() = CONS(list, TRECONTEXT_FUNSTACK());
}

void
trethread_pop_call ()
{
    treptr tmp;

    tmp = TRECONTEXT_FUNSTACK();
    TRECONTEXT_FUNSTACK() = CDR(TRECONTEXT_FUNSTACK());
    TRELIST_FREE_EARLY(tmp);
}
