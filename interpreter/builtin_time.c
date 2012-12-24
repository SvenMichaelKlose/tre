/*
 * tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "builtin_time.h"

#include <time.h>

/*
 * (NANOTIME)
 *
 * Get number of nanoseconds since the epoch.
 */
treptr
tretime_builtin_nanotime (treptr dummy)
{
    struct timespec ts;

    (void) dummy;

    clock_gettime (CLOCK_PROCESS_CPUTIME_ID, &ts);
    return treatom_number_get (ts.tv_nsec + (ts.tv_sec * 1000000000), TRENUMTYPE_FLOAT);
}
