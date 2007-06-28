/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in number-related functions
 */

#ifndef LISP_BUILTIN_ARITH_H
#define LISP_BUILTIN_ARITH_H

extern lispptr lispnumber_builtin_plus (lispptr);
extern lispptr lispnumber_builtin_difference (lispptr);
extern lispptr lispnumber_builtin_times (lispptr);
extern lispptr lispnumber_builtin_quotient (lispptr);
extern lispptr lispnumber_builtin_mod (lispptr);
extern lispptr lispnumber_builtin_logxor (lispptr);
extern lispptr lispnumber_builtin_number_equal (lispptr);
extern lispptr lispnumber_builtin_lessp (lispptr);
extern lispptr lispnumber_builtin_greaterp (lispptr);

#endif	/* #ifndef LISP_BUILTIN_ARITH_H */
