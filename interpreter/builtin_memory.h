/*
 * tré – Copyright (c) 2005–2006,2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_MEMORY_H
#define TRE_BUILTIN_MEMORY_H

extern treptr trebuiltin_get (treptr);
extern treptr trebuiltin_set (treptr);
extern treptr trebuiltin_malloc (treptr);
extern treptr trebuiltin_malloc_exec (treptr);
extern treptr trebuiltin_free (treptr);
extern treptr trebuiltin_free_exec (treptr);

#endif	/* #ifndef TRE_BUILTIN_MEMORY_H */
