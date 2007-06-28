/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Array-related section.
 */

#ifndef LISP_ARRAY_H
#define LISP_ARRAY_H

extern void lisparray_init (void);

extern lispptr lisparray_get (lispptr sizes);
extern void lisparray_free (lispptr);
extern unsigned lisparray_get_size (lispptr sizes);

extern struct lisp_sequence_type lisparray_seqtype;

#define LISPARRAY_SIZE(arr) (lisparray_get_size (LISPATOM_VALUE(arr)))

#endif
