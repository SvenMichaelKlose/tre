/*
 * TRE interpreter
 * Copyright (c) 2005-2006,2009 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#ifndef TRE_BUILTIN_H
#define TRE_BUILTIN_H

extern char *tre_builtin_names[];
extern treevalfunc_t treeval_xlat_builtin[];

extern treptr trebuiltin (treptr func, treptr expr);

/* for compiled code */
extern treptr trebuiltin_print (treptr);
extern treptr trebuiltin_eval (treptr);
extern treptr trebuiltin_macrocall (treptr);
extern treptr trebuiltin_get (treptr);
extern treptr trebuiltin_set (treptr);
extern treptr trebuiltin_malloc (treptr);
extern treptr trebuiltin_free (treptr);
extern treptr trebuiltin_load (treptr);

#endif	/* #ifndef TRE_BUILTIN_H */
