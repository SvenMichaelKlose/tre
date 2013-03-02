/*
 * tré – Copyright (c) 2005-2007,2009 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ARRAY_H
#define TRE_ARRAY_H

extern void trearray_init (void);

extern treptr trearray_get (treptr sizes);
extern void   trearray_free (treptr);
extern size_t trearray_get_size (treptr sizes);

extern struct tre_sequence_type trearray_seqtype;

/* for compiled code */
extern treptr trearray_make (ulong size);

#define TREARRAY_SIZE(arr) (trearray_get_size (TREATOM_VALUE(arr)))
#define TREARRAY_RAW(arr) ((treptr *) (TREATOM_DETAIL(arr)))

#endif
