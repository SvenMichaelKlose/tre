/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Sequence-related section.
 */

#ifndef TRE_SEQUENCE_H
#define TRE_SEQUENCE_H

/*
 * Access to sequences is dispatched. For each sequence type a
 * tre_sequence_type must be defined.
 */
struct tre_sequence_type {
     void (*set) (treptr, unsigned, treptr);
     treptr (*get) (treptr, unsigned);
     unsigned (*length) (treptr);
};

extern treptr tresequence_builtin_elt (treptr);
extern treptr tresequence_builtin_set_elt (treptr);
extern treptr tresequence_builtin_length (treptr);

#endif
