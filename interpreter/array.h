/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Array-related section.
 */

#ifndef TRE_ARRAY_H
#define TRE_ARRAY_H

extern void trearray_init (void);

extern treptr trearray_get (treptr sizes);
extern void trearray_free (treptr);
extern unsigned trearray_get_size (treptr sizes);

extern struct tre_sequence_type trearray_seqtype;

#define TREARRAY_SIZE(arr) (trearray_get_size (TREATOM_VALUE(arr)))

#endif
