/*
 * tré - Copyright (c) 2005-2009 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ALLOC_H
#define TRE_ALLOC_H

#include "ctype2.h"

#include <sys/types.h>

extern treptr trealloc_used;
extern treptr trealloc_unused;

extern void * trealloc (size_t);
extern void   trealloc_free (void *);

extern void * trealloc_item (void * handle);
extern void   trealloc_free_item (void * handle, void * item);
extern void * trealloc_item_init (void * map, ulong num_items, ulong item_size);

#endif
