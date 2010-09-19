/*
 * TRE interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in list functions
 */

#ifndef TRE_BUILTIN_DEBUG_H
#define TRE_BUILTIN_DEBUG_H

extern treptr tredebug_builtin_end_debug (treptr);
extern treptr tredebug_builtin_invoke_debugger (treptr);
extern treptr tredebug_builtin_set_breakpoint (treptr);
extern treptr tredebug_builtin_remove_breakpoint (treptr);


#endif	/* #ifndef TRE_BUILTIN_DEBUG_H */
