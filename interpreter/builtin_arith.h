/*
 * tré – Copyright (c) 2005–2006,2010,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_ARITH_H
#define TRE_BUILTIN_ARITH_H

extern treptr trenumber_builtin_plus (treptr);
extern treptr trenumber_builtin_character_plus (treptr);
extern treptr trenumber_builtin_difference (treptr);
extern treptr trenumber_builtin_character_difference (treptr);
extern treptr trenumber_builtin_times (treptr);
extern treptr trenumber_builtin_quotient (treptr);
extern treptr trenumber_builtin_mod (treptr);
extern treptr trenumber_builtin_logxor (treptr);
extern treptr trenumber_builtin_sqrt (treptr);
extern treptr trenumber_builtin_sin (treptr);
extern treptr trenumber_builtin_cos (treptr);
extern treptr trenumber_builtin_atan (treptr);
extern treptr trenumber_builtin_atan2 (treptr);
extern treptr trenumber_builtin_random (treptr);
extern treptr trenumber_builtin_exp (treptr);
extern treptr trenumber_builtin_number_equal (treptr);
extern treptr trenumber_builtin_lessp (treptr);
extern treptr trenumber_builtin_greaterp (treptr);

#endif	/* #ifndef TRE_BUILTIN_ARITH_H */
