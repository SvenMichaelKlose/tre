/*
 * tré - Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 */

#include "config.h"
#include "xxx.h"
#include "ptr.h"
#include "alloc.h"

#include <stdlib.h>

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

void *
trealloc_item (void * start)
{
	void * first = *((void **) start);
	if (!first)
		return NULL;

	*((void **) start) = *((void **) first);
	return first;
}

void
trealloc_free_item (void * start, void * item)
{
	*((void **) item) = *((void **) start);
	*((void **) start) = item;
}

void *
trealloc_item_init (void * map, ulong num, ulong size)
{
	void * last = NULL;

	while (num--) {
		*((void **) map) = last;
		last = map;
		map += size;
	}
	return last;
}
