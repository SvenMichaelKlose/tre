/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#ifndef TRE_ALIEN_DL_H
#define TRE_ALIEN_DL_H

extern treptr trealien_builtin_dlopen (treptr);
extern treptr trealien_builtin_dlsym (treptr);
extern treptr trealien_builtin_dlclose (treptr);
extern treptr trealien_builtin_dlcall0 (treptr);
extern treptr trealien_builtin_dlcall1 (treptr);
extern treptr trealien_builtin_dlcall2 (treptr);
extern treptr trealien_builtin_dlcall3 (treptr);
extern treptr trealien_builtin_dlcall4 (treptr);

#endif	/* #ifndef TRE_ALIEN_DL_H */
