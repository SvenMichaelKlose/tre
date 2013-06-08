/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SEQUENCE_H
#define TRE_SEQUENCE_H

struct tre_sequence_type {
     void     (*set) (treptr, tre_size, treptr);
     treptr   (*get) (treptr, tre_size);
     tre_size (*length) (treptr);
};

extern treptr tresequence_builtin_elt (treptr);
extern treptr tresequence_builtin_set_elt (treptr);
extern treptr tresequence_builtin_length (treptr);

#endif
