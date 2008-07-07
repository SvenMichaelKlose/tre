/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#ifndef TRE_ENV_H
#define TRE_ENV_H

#define TREENV_SYMBOLS(e)     (CAR(CDR(e)))
#define TREENV_BINDINGS(e)    (CDR(CDR(e)))
#define TREENV_PARENT(e)      (CAR(e))
#define TREENV_SET_SYMBOLS(e, v)    (RPLACA(CDR(e), v))
#define TREENV_SET_BINDINGS(e, v)   (RPLACD(CDR(e), v))

/*
 * Environment structure
 */

/* Create new environment for atom. */
extern void treenv_create (treptr a);

/* Update bindings of environment. */
extern void treenv_update (treptr env, treptr atoms, treptr values);

/*
 * Argument bindings
 */

/* Bind each atom to new value. Lists must have the same size. */
extern void treenv_bind (treptr atoms, treptr values);

/* Bind each atom to new value. Stop if shorter list ended. */
extern void treenv_bind_sloppy (treptr atoms, treptr values);

/* Unbind each atom. */
extern void treenv_unbind (treptr atoms);

/*
 * Environment bindings
 */

extern treptr treenv_scope_buffer;

/* Bind parent environments until one matches 'parent'. */
extern void treenv_bind_env (treptr env, treptr parent);
/* Unbind parent environments until one matches 'parent'. */
extern void treenv_unbind_env (treptr env, treptr parent);

#endif	/* #ifndef TRE_ENV_H */
