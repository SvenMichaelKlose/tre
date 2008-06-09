/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#ifndef TRE_ALIEN_DL_H
#define TRE_ALIEN_DL_H

extern treptr trealien_builtin_call (treptr);
extern treptr trealien_builtin_call_1 (treptr);

extern treptr trealien_builtin_dlopen (treptr);
extern treptr trealien_builtin_dlsym (treptr);
extern treptr trealien_builtin_dlclose (treptr);

#endif	/* #ifndef TRE_ALIEN_DL_H */
