/*
 * tré - Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_SEQUENCE_H
#define TRE_SEQUENCE_H

/*
 * Access to sequences is dispatched. For each sequence type a
 * tre_sequence_type must be defined.
 */
struct tre_sequence_type {
     void    (*set) (treptr, ulong, treptr);
     treptr  (*get) (treptr, ulong);
     size_t  (*length) (treptr);
};

extern treptr tresequence_builtin_elt (treptr);
extern treptr tresequence_builtin_set_elt (treptr);
extern treptr tresequence_builtin_length (treptr);

#endif
