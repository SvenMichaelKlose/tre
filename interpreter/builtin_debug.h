/*
 * tré – Copyright (c) 2005–2006,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_BUILTIN_DEBUG_H
#define TRE_BUILTIN_DEBUG_H

extern treptr tredebug_builtin_end_debug (treptr);
extern treptr tredebug_builtin_invoke_debugger (treptr);
extern treptr tredebug_builtin_set_breakpoint (treptr);
extern treptr tredebug_builtin_remove_breakpoint (treptr);

#endif	/* #ifndef TRE_BUILTIN_DEBUG_H */

#endif /* #ifdef INTERPRETER */
