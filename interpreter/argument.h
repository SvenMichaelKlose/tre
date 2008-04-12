/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Argument-related section
 */

#ifndef TRE_ARGUMENTS_H
#define TRE_ARGUMENTS_H

extern void trearg_get2 (treptr *car, treptr *cdr, treptr args);
extern treptr trearg_get (treptr args);

extern treptr trearg_correct (int type, int argnum, const char * descr, treptr);

extern treptr trearg_typed (int type, int argnum, const char * descr, treptr);
extern treptr trearg_cons (int argnum, const char * descr, treptr);
extern treptr trearg_atom (int argnum, const char * descr, treptr);
extern treptr trearg_variable (int argnum, const char * descr, treptr);
extern treptr trearg_number (int argnum, const char * descr, treptr);
extern treptr trearg_array (int argnum, const char * descr, treptr);
extern treptr trearg_string (int argnum, const char * descr, treptr);
extern treptr trearg_macro (int argnum, const char * descr, treptr);

extern void trearg_expand (treptr *rvars, treptr *rvals,
                            treptr argdef, treptr args,
                            bool do_argeval);

extern void trearg_init (void);

/* Return atom with same symbol in keyword package. */
extern void trearg_apply_keyword_package (treptr atom);

extern treptr tre_atom_rest;

#endif 	/* #ifndef TRE_ARGUMENTS_H */
