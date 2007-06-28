/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Utility functions
 */

#ifndef LISP_ENV_H
#define LISP_ENV_H

#define LISPENV_SYMBOLS(e)     (CAR(CDR(e)))
#define LISPENV_BINDINGS(e)    (CDR(CDR(e)))
#define LISPENV_PARENT(e)      (CAR(e))
#define LISPENV_SET_SYMBOLS(e, v)    (RPLACA(CDR(e), v))
#define LISPENV_SET_BINDINGS(e, v)   (RPLACD(CDR(e), v))

/*
 * Environment structure
 */

/* Create new environment for atom. */
extern void lispenv_create (lispptr a);

/* Update bindings of environment. */
extern void lispenv_update (lispptr env, lispptr atoms, lispptr values);

/*
 * Argument bindings
 */

/* Bind each atom to new value. Lists must have the same size. */
extern void lispenv_bind (lispptr atoms, lispptr values);

/* Bind each atom to new value. Stop if shorter list ended. */
extern void lispenv_bind_sloppy (lispptr atoms, lispptr values);

/* Unbind each atom. */
extern void lispenv_unbind (lispptr atoms);

/*
 * Environment bindings
 */

/* Bind parent environments until one matches 'parent'. */
extern void lispenv_bind_env (lispptr env, lispptr parent);
/* Unbind parent environments until one matches 'parent'. */
extern void lispenv_unbind_env (lispptr env, lispptr parent);

#endif	/* #ifndef LISP_ENV_H */
