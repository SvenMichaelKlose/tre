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

extern void * trealloc_item (void * handle, void * map, void * end);
extern void trealloc_free_item (void * handle, void * item, void * map, void * end);
extern void * trealloc_item_init (void * map, unsigned num_items, unsigned item_size);

#endif
