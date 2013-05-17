/*
 * tré – Copyright (c) 2005–2009,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ALLOC_H
#define TRE_ALLOC_H

#include <sys/types.h>

extern treptr trealloc_used;
extern treptr trealloc_unused;

extern void * trealloc_item (void * handle);
extern void   trealloc_free_item (void * handle, void * item);
extern void * trealloc_item_init (void * map, size_t num_items, size_t item_size);

#endif
