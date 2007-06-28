/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Memory allocation.
 */

#include "lisp.h"
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

void
lispalloc_init (void)
{
}

void *
lispalloc (size_t size)
{
    return malloc (size);
}

void
lispalloc_free (void *p)
{
    free (p);
}
