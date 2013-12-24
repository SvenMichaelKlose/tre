/*
 * tré – Copyright (c) 2005–2007,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

/*
 * NOTE: There's only a single thread.
 */

#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "thread.h"

struct tre_thread_context tre_context;

void
trethread_make ()
{
    TRECONTEXT_FUNSTACK() = treptr_nil;
    TRECONTEXT_PACKAGE() = treptr_nil;
}

void
trethread_push_call (treptr list)
{
    (void) list;
}

void
trethread_pop_call ()
{
}
