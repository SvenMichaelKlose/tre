/*
 * tré – Copyright (c) 2005–2008,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_ENV_H
#define TRE_ENV_H

extern void treenv_create (treptr a);
extern void treenv_bind (treptr atoms, treptr values);
extern void treenv_unbind (treptr atoms);

#endif	/* #ifndef TRE_ENV_H */

#endif /* #ifdef INTERPRETER */
