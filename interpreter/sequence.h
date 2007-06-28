/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Sequence-related section.
 */

#ifndef LISP_SEQUENCE_H
#define LISP_SEQUENCE_H

/*
 * Access to sequences is dispatched. For each sequence type a
 * lisp_sequence_type must be defined.
 */
struct lisp_sequence_type {
     void (*set) (lispptr, unsigned, lispptr);
     lispptr (*get) (lispptr, unsigned);
     unsigned (*length) (lispptr);
};

extern lispptr lispsequence_builtin_elt (lispptr);
extern lispptr lispsequence_builtin_set_elt (lispptr);
extern lispptr lispsequence_builtin_length (lispptr);

#endif
