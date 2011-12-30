/*
 * tré - Copyright (c) 2011 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_QUEUE_H
#define TRE_QUEUE_H

#include "ptr.h"

#define DOQUEUE(iter, queue)  DOLIST(iter, tre_queue_list (queue))

treptr tre_make_queue ();
void tre_enqueue (treptr queue, treptr value);
treptr tre_queue_list (treptr queue);
bool tre_queue_is_empty (treptr queue);
void tre_queue_pop (treptr queue);

#endif /* #ifndef TRE_QUEUE_H */
