/*
 * tré – Copyright (c) 2005–2007,2009,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_APPLY_H
#define TRE_APPLY_H

extern treptr function_arguments (treptr);

extern treptr trefuncall (treptr func, treptr args);
extern treptr trebuiltin_call_compiled (void * fun, treptr args);

extern bool   trebuiltin_is_compiled_funcall (treptr);
extern bool   trebuiltin_is_compiled_closure (treptr);
extern treptr trefuncall_compiled (treptr func, treptr args, bool do_eval);

void treapply_init ();

#endif	/* #ifndef TRE_APPLY_H */
