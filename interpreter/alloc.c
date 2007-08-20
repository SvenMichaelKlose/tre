/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Memory allocation.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "sequence.h"
#include "array.h"
#include "argument.h"
#include "util.h"

#include <stdlib.h>

#include "alloc.h"

void *
trealloc (size_t size)
{
    return malloc (size);
}

void
trealloc_free (void *p)
{
    free (p);
}
