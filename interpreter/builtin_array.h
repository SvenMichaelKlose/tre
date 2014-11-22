/*
 * tré – Copyright (c) 2005–2006,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_ARRAY_H
#define TRE_BUILTIN_ARRAY_H

extern treptr trearray_p (treptr);
extern treptr trearray_aref (treptr, treptr);
extern treptr trearray_set_aref (treptr, treptr, treptr);

extern treptr trearray_builtin_make (treptr);

#endif
