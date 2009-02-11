/*
 * TRE interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Memory allocation.
 */

#include "config.h"
#include "xxx.h"
#include "ptr.h"
#include "alloc.h"

#include <stdlib.h>
#ifdef TRE_DIAGNOSTICS
	#include <stdio.h>
#endif

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

#ifdef TRE_DIAGNOSTICS
void
trealloc_item_diag (void * ptr, void * map, void * end)
{
	if (ptr < map) {
		printf ("trealloc_item: <!\n");
		CRASH();
	}
	if (ptr >= end) {
		printf ("trealloc_item: <!\n");
		CRASH();
	}
}
#define TREALLOC_ITEM_DIAG(ptr, map, end) trealloc_item_diag (ptr, map, end)
#else
#define TREALLOC_ITEM_DIAG(ptr, map, end)
#endif

void *
trealloc_item (void * start, void * map, void * end)
{
	void * first = *((void **) start);
	if (!first)
		return NULL;

	TREALLOC_ITEM_DIAG(*(void **) start, map, end);
	TREALLOC_ITEM_DIAG(first, map, end);
	*((void **) start) = *((void **) first);
	return first;
}

void
trealloc_free_item (void * start, void * item, void * map, void * end)
{
#ifdef TRE_DIAGNOSTICS
	if (*(void **) start)
		TREALLOC_ITEM_DIAG(*(void **) start, map, end);
#endif
	TREALLOC_ITEM_DIAG(item, map, end);
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
