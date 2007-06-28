/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in list functions
 */

#ifndef LISP_BUILTIN_DEBUG_H
#define LISP_BUILTIN_DEBUG_H

extern lispptr lispdebug_builtin_end_debug (lispptr);
extern lispptr lispdebug_builtin_invoke_debugger (lispptr);
extern lispptr lispdebug_builtin_set_breakpoint (lispptr);
extern lispptr lispdebug_builtin_remove_breakpoint (lispptr);


#endif	/* #ifndef LISP_BUILTIN_DEBUG_H */
