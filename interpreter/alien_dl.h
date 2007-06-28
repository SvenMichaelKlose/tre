/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#ifndef LISP_ALIEN_DL_H
#define LISP_ALIEN_DL_H

extern lispptr lispalien_builtin_dlopen (lispptr);
extern lispptr lispalien_builtin_dlsym (lispptr);
extern lispptr lispalien_builtin_dlclose (lispptr);
extern lispptr lispalien_builtin_dlcall0 (lispptr);
extern lispptr lispalien_builtin_dlcall1 (lispptr);
extern lispptr lispalien_builtin_dlcall2 (lispptr);
extern lispptr lispalien_builtin_dlcall3 (lispptr);
extern lispptr lispalien_builtin_dlcall4 (lispptr);

#endif	/* #ifndef LISP_ALIEN_DL_H */
