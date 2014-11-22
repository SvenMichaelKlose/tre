/*
 * tré – Copyright (c) 2011 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_QUEUE_H
#define TRE_QUEUE_H

#include "ptr.h"

#define DOQUEUE(iter, queue)  DOLIST(iter, tre_queue_list (queue))

extern treptr tre_make_queue ();
extern void   tre_enqueue (treptr queue, treptr value);
extern treptr tre_queue_list (treptr queue);
extern bool   tre_queue_is_empty (treptr queue);
extern void   tre_queue_pop (treptr queue);

#endif /* #ifndef TRE_QUEUE_H */
