/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in number-related functions
 */

#ifndef TRE_BUILTIN_ARITH_H
#define TRE_BUILTIN_ARITH_H

extern treptr trenumber_builtin_plus (treptr);
extern treptr trenumber_builtin_difference (treptr);
extern treptr trenumber_builtin_times (treptr);
extern treptr trenumber_builtin_quotient (treptr);
extern treptr trenumber_builtin_mod (treptr);
extern treptr trenumber_builtin_logxor (treptr);
extern treptr trenumber_builtin_number_equal (treptr);
extern treptr trenumber_builtin_lessp (treptr);
extern treptr trenumber_builtin_greaterp (treptr);

#endif	/* #ifndef TRE_BUILTIN_ARITH_H */
