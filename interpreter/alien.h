/*
 * tré - Copyright (c) 2005-2006 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_ALIEN_DL_H
#define TRE_ALIEN_DL_H

extern treptr trealien_builtin_call (treptr);
extern treptr trealien_builtin_dlopen (treptr);
extern treptr trealien_builtin_dlsym (treptr);
extern treptr trealien_builtin_dlclose (treptr);

#endif	/* #ifndef TRE_ALIEN_DL_H */
