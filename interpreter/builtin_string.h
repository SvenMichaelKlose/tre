/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * String-type related section.
 */

#ifndef TRE_BUILTIN_STRING_H
#define TRE_BUILTIN_STRING_H

extern treptr trestring_builtin_stringp (treptr);
extern treptr trestring_builtin_concat (treptr);
extern treptr trestring_builtin_make (treptr);

extern treptr trestring_builtin_symbol_name (treptr);
extern treptr trestring_builtin_string (treptr);

#endif
