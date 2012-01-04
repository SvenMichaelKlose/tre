/*
 * tré - Copyright (c) 2005-2008,2010 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_NUMBER_H
#define TRE_BUILTIN_NUMBER_H

extern treptr trenumber_builtin_numberp (treptr);
extern treptr trenumber_code_char (treptr);
extern treptr trenumber_builtin_code_char (treptr);
extern treptr trenumber_builtin_integer (treptr);
extern treptr trenumber_builtin_characterp (treptr);
extern treptr trenumber_builtin_bit_or (treptr);
extern treptr trenumber_builtin_bit_and (treptr);
extern treptr trenumber_builtin_bit_shift_left (treptr);
extern treptr trenumber_builtin_bit_shift_right (treptr);

#endif
