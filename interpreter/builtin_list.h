/*
 * tré – Copyright (c) 2005–2006,2009,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_LIST_H
#define TRE_BUILTIN_LIST_H

extern treptr trelist_builtin_cons (treptr);
extern treptr trelist_builtin_list (treptr);
extern treptr trelist_builtin_car (treptr);
extern treptr trelist_builtin_cdr (treptr);
extern treptr trelist_builtin_cpr (treptr);
extern treptr trelist_builtin_rplaca (treptr);
extern treptr trelist_builtin_rplacd (treptr);
extern treptr trelist_builtin_rplacp (treptr);
extern treptr trelist_builtin_consp (treptr);
extern treptr trelist_builtin_assoc (treptr);
extern treptr trelist_builtin_member (treptr);
extern void   trelist_builtin_init ();

#endif	/* #ifndef TRE_BUILTIN_LIST_H */
