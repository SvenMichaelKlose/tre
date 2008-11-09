/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Argument-related section
 */

#ifndef TRE_ARGUMENTS_H
#define TRE_ARGUMENTS_H

extern void trearg_get2 (treptr *car, treptr *cdr, treptr args);
extern treptr trearg_get (treptr args);

extern treptr trearg_correct (ulong argnum, int type, treptr, const char * descr);
extern treptr trearg_typed (ulong argnum, int type, treptr, const char * descr);

extern void trearg_expand (treptr *rvars, treptr *rvals,
                            treptr argdef, treptr args,
                            bool do_argeval);

extern void trearg_init (void);

extern treptr tre_atom_rest;

#endif 	/* #ifndef TRE_ARGUMENTS_H */
