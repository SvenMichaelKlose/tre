/*
 * tré – Copyright (c) 2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <time.h>

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "builtin_time.h"

treptr
tretime_builtin_nanotime (treptr dummy)
{
    struct timespec ts;

    (void) dummy;

    clock_gettime (CLOCK_PROCESS_CPUTIME_ID, &ts);
    return number_get_float (ts.tv_nsec + (ts.tv_sec * 1000000000));
}
