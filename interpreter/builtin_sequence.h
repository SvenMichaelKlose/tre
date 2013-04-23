/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SEQUENCE_H
#define TRE_SEQUENCE_H

struct tre_sequence_type {
     void    (*set) (treptr, size_t, treptr);
     treptr  (*get) (treptr, size_t);
     size_t  (*length) (treptr);
};

extern treptr tresequence_builtin_elt (treptr);
extern treptr tresequence_builtin_set_elt (treptr);
extern treptr tresequence_builtin_length (treptr);

#endif
