/*
 * tré – Copyright (c) 2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "error.h"
#include "gc.h"

treptr
tre_make_queue ()
{
    return CONS(treptr_nil, treptr_nil);
}

void
tre_enqueue (treptr queue, treptr value)
{
    treptr new;

    treptr last = CAR(queue);
    if (NOT(last))
        last = queue;

    tregc_push (value);

    new = CONS(value, treptr_nil);
    RPLACD(last, new);
    RPLACA(queue, new);

    tregc_pop ();
}

treptr
tre_queue_list (treptr queue)
{
    return CDR(queue);
}

bool
tre_queue_is_empty (treptr queue)
{
   return NOT(CAR(queue));
}

void
tre_queue_pop (treptr queue)
{
    RPLACD(queue, CDR(CDR(queue)));
    if (NOT(CDR(queue)))
        RPLACA(queue, treptr_nil);
}
