/*
 * tré – Copyright (c) 2005–2007,2009,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_APPLY_H
#define TRE_BUILTIN_APPLY_H

extern treptr function_arguments (treptr);

extern treptr trebuiltin_funcall0 (treptr func, treptr args);
extern treptr trebuiltin_funcall (treptr);
extern treptr trebuiltin_apply (treptr);
extern treptr trebuiltin_call_compiled (treptr func, treptr args);

extern bool   trebuiltin_is_compiled_funcall (treptr);
extern treptr treeval_compiled_expr (treptr func, treptr expr, treptr argdef, bool do_eval);
extern treptr trebuiltin_apply_bytecode_call (treptr func, treptr args, bool do_eval);

void trebuiltin_apply_init ();

#endif	/* #ifndef TRE_BUILTIN_APPLY_H */
