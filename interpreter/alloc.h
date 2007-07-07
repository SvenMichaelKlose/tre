/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Memory allocation.
 */

#ifndef LISP_ALLOC_H
#define LISP_ALLOC_H

#include <wordexp.h>

extern lispptr lispalloc_used;
extern lispptr lispalloc_unused;

extern void *lispalloc (size_t);
extern void lispalloc_free (void *);

#endif
