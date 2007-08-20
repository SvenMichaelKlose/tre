/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Memory allocation.
 */

#ifndef TRE_ALLOC_H
#define TRE_ALLOC_H

#include <wordexp.h>

extern treptr trealloc_used;
extern treptr trealloc_unused;

extern void *trealloc (size_t);
extern void trealloc_free (void *);

#endif
