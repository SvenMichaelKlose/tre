/*
 * tré – Copyright (c) 2005–2006,2009,2011–2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_H
#define TRE_BUILTIN_H

extern char *tre_builtin_names[];
extern treevalfunc_t treeval_xlat_builtin[];

extern treptr trebuiltin (treptr func, treptr expr);

/* for compiled code */
extern treptr trebuiltin_apply (treptr);
extern treptr trebuiltin_print (treptr);
extern treptr trebuiltin_eval (treptr);
extern treptr trebuiltin_macrocall (treptr);
extern treptr trebuiltin_get (treptr);
extern treptr trebuiltin_set (treptr);
extern treptr trebuiltin_malloc (treptr);
extern treptr trebuiltin_malloc_exec (treptr);
extern treptr trebuiltin_free (treptr);
extern treptr trebuiltin_free_exec (treptr);
extern treptr trebuiltin_load (treptr);
extern treptr trebuiltin_quit (treptr);

#endif	/* #ifndef TRE_BUILTIN_H */
