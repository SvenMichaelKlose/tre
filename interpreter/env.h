/*
 * tré – Copyright (c) 2005–2008,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_ENV_H
#define TRE_ENV_H

#define TREENV_SYMBOLS(e)     (CAR(CDR(e)))
#define TREENV_BINDINGS(e)    (CDR(CDR(e)))
#define TREENV_PARENT(e)      (CAR(e))
#define TREENV_SET_SYMBOLS(e, v)    (RPLACA(CDR(e), v))
#define TREENV_SET_BINDINGS(e, v)   (RPLACD(CDR(e), v))

extern void treenv_create (treptr a);
extern void treenv_bind (treptr atoms, treptr values);
extern void treenv_bind_sloppy (treptr atoms, treptr values);
extern void treenv_unbind (treptr atoms);

#endif	/* #ifndef TRE_ENV_H */

#endif /* #ifdef INTERPRETER */
