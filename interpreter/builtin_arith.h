/*
 * tré – Copyright (c) 2005–2006,2010,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_ARITH_H
#define TRE_BUILTIN_ARITH_H

extern treptr trenumber_plus (treptr, treptr);
extern treptr trenumber_difference (treptr, treptr);
extern treptr trenumber_mod (treptr, treptr);
extern treptr trenumber_sqrt (treptr);
extern treptr trenumber_sin (treptr);
extern treptr trenumber_cos (treptr);
extern treptr trenumber_atan (treptr);
extern treptr trenumber_atan2 (treptr, treptr);
extern treptr trenumber_random ();
extern treptr trenumber_exp (treptr);
extern treptr trenumber_pow (treptr, treptr);
extern treptr trenumber_round (treptr);
extern treptr trenumber_floor (treptr);
extern treptr trenumber_equal (treptr, treptr);
extern treptr trenumber_lessp (treptr, treptr);
extern treptr trenumber_greaterp (treptr, treptr);

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
extern treptr trenumber_builtin_pow (treptr);
extern treptr trenumber_builtin_round (treptr);
extern treptr trenumber_builtin_floor (treptr);
extern treptr trenumber_builtin_number_equal (treptr);
extern treptr trenumber_builtin_lessp (treptr);
extern treptr trenumber_builtin_greaterp (treptr);

extern void   trebuiltin_arith_init (void);

#endif	/* #ifndef TRE_BUILTIN_ARITH_H */
