/*
 * tré – Copyright (c) 2005–2006,2009,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_STRING_H
#define TRE_BUILTIN_STRING_H

extern treptr trestring_p (treptr);
extern treptr trestring_symbol_name (treptr);

extern treptr trestring_builtin_stringp (treptr);
extern treptr trestring_builtin_list_string (treptr);
extern treptr trestring_builtin_compare (treptr);
extern treptr trestring_builtin_concat (treptr);
extern treptr trestring_builtin_make (treptr);

#endif
