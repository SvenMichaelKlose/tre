/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Number-related section.
 */

#ifndef TRE_BUILTIN_NUMBER_H
#define TRE_BUILTIN_NUMBER_H

extern treptr trenumber_builtin_numberp (treptr);
extern treptr trenumber_builtin_code_char (treptr);
extern treptr trenumber_builtin_integer (treptr);
extern treptr trenumber_builtin_characterp (treptr);

#endif
