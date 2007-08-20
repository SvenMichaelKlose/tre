/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in list functions
 */

#ifndef TRE_BUILTIN_LIST_H
#define TRE_BUILTIN_LIST_H

extern treptr trelist_builtin_cons (treptr);
extern treptr trelist_builtin_list (treptr);
extern treptr trelist_builtin_car (treptr);
extern treptr trelist_builtin_cdr (treptr);
extern treptr trelist_builtin_rplaca (treptr);
extern treptr trelist_builtin_rplacd (treptr);
extern treptr trelist_builtin_consp (treptr);

#endif	/* #ifndef TRE_BUILTIN_LIST_H */
