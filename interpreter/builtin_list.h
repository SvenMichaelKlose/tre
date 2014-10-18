/*
 * tré – Copyright (c) 2005–2006,2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_LIST_H
#define TRE_BUILTIN_LIST_H

extern treptr list_consp (treptr);

extern treptr list_builtin_cons   (treptr);
extern treptr list_builtin_car    (treptr);
extern treptr list_builtin_cdr    (treptr);
extern treptr list_builtin_cpr    (treptr);
extern treptr list_builtin_rplaca (treptr);
extern treptr list_builtin_rplacd (treptr);
extern treptr list_builtin_rplacp (treptr);
extern treptr list_builtin_consp  (treptr);
extern treptr list_builtin_last   (treptr);

#endif	/* #ifndef TRE_BUILTIN_LIST_H */
