/*
 * tré – Copyright (c) 2005–2006,2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_H
#define TRE_BUILTIN_H

extern char *tre_builtin_names[];
extern evalfunc_t eval_xlat_builtin[];

extern treptr trebuiltin (treptr func, treptr expr);

/* For compiled environment. */
extern treptr trebuiltin_apply (treptr);
extern treptr trebuiltin_load (treptr);
extern treptr trebuiltin_quit (treptr);
extern treptr trebuiltin_debug (treptr);
extern treptr trebuiltin_gc (treptr);

extern void   trebuiltin_init (void);

#endif	/* #ifndef TRE_BUILTIN_H */
