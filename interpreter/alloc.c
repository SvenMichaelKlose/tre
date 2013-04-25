/*
 * tré – Copyright (c) 2005–2009,2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>

#include "config.h"
#include "xxx.h"
#include "ptr.h"
#include "alloc.h"

void *
trealloc (size_t size)
{
    return malloc (size);
}

void
trealloc_free (void * p)
{
    free (p);
}

void *
trealloc_item (void * start)
{
    void ** p = (void **) start;
	void ** first = *p;

	if (!first)
		return NULL;

	*p = *first;
	return first;
}

void
trealloc_free_item (void * start, void * item)
{
    void ** p = (void **) start;
    void ** i = (void **) item;

	*i = *p;
	*p = i;
}

void *
trealloc_item_init (void * start, size_t num, size_t size)
{
    void ** p = (void **) start;
	void *  last = NULL;

	while (num--) {
		*p = last;
		last = p;
		p = ((void *) p) + size;
	}

	return last;
}
