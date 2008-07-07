/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Environment
 *
 * The interpreter uses lexical scoping. Dynamic scoping is
 * a subset of lexical scoping and implemented by binding the atoms of
 * arguments to new values until the function returns. Each atom has a
 * stack of bound values for this purpose (symbols and bindings).
 *
 * For lexical scoping the bindings of a function call are stored in
 * the function atoms detail field. Additionally, the environments of the
 * lexically parent functions are bound before the argument.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "env.h"
#include "special.h"
#include "error.h"
#include "gc.h"
#include "debug.h"
#include "thread.h"
#include "diag.h"
#include "xxx.h"

#include <stdlib.h>

/* Create new environment for atom. */
void
treenv_create (treptr a)
{
    TREATOM_DETAIL(a) = (void *) 
        CONS(TRECONTEXT_ENV_CURRENT(), CONS(treptr_nil, treptr_nil));
}
/* Update bindings of environment. */
void
treenv_update (treptr env, treptr atoms, treptr values)
{
    RETURN_IF_NIL(env);
    TREENV_SET_SYMBOLS(env, trelist_copy (atoms));
    TREENV_SET_BINDINGS(env, trelist_copy (values));
}

#define PUSH_BINDING(x)	(TREATOM_BINDING(x) = CONS(TREATOM_VALUE(x), TREATOM_BINDING(x)))

/*
 * Argument bindings
 */

/* Bind argument list to atoms. */
void
treenv_bind (treptr la, treptr lv)
{
    treptr  arg;
    treptr  val;

    for (;la != treptr_nil && lv != treptr_nil; la = CDR(la), lv = CDR(lv)) {
        arg = CAR(la);
        val = CAR(lv);
#ifdef TRE_DIAGNOSTICS
        if (TREPTR_IS_VARIABLE(arg) == FALSE)
            treerror_internal (arg, "bind: variable expected");
#endif

		PUSH_BINDING(arg);
		TREATOM_VALUE(arg) = val;
    }

    if (la != treptr_nil)
        treerror (la, "arguments missing");
    if (lv != treptr_nil)
        treerror (lv, "too many arguments. Rest of forms");
}

/*
 * Argument bindings
 */

/* Bind argument list to atoms. Stop if the shorter list ends. */
void
treenv_bind_sloppy (treptr la, treptr lv)
{
    treptr  car;
    
    while (la != treptr_nil) {
        car = CAR(la);
#ifdef TRE_DIAGNOSTICS
        if (TREPTR_IS_VARIABLE(car) == FALSE)
            treerror_internal (car, "sloppy bind: variable expexted");
#endif  
        
        /* Push value on binding list. */
		PUSH_BINDING(car);
        TREATOM_VALUE(car) = (lv != treptr_nil) ? CAR(lv) : treptr_nil;

        la = CDR(la);
        if (lv != treptr_nil)
            lv = CDR(lv);
    }
}

/* Unbind argument list from atoms. */
void
treenv_unbind (treptr la)
{
    treptr  bding;
    treptr  car;

    for (;la != treptr_nil; la = CDR(la)) {
        car = CAR(la);
        bding = TREATOM_BINDING(car);
        TREATOM_VALUE(car) = CAR(bding);
        TREATOM_BINDING(car) = CDR(bding);
        TRELIST_FREE_EARLY(bding);
    }
}

/*
 * Environment bindings
 */

treptr treenv_scope_buffer;

/* Bind parent environments until one matches 'parent'. */
void
treenv_bind_env (treptr env, treptr parent)
{
	treptr x;

    RETURN_IF_NIL(env);
    RETURN_IF_NIL(TREENV_PARENT(env));

	/* Read scope environments into list, so it can be reversed into the right order. */
	treenv_scope_buffer = treptr_nil;
	tregc_push (treenv_scope_buffer);

    for (env = TREENV_PARENT(env); env != treptr_nil && env != parent; env = TREENV_PARENT(env))
		TRELIST_PUSH(treenv_scope_buffer, env);

	_DOLIST(x, treenv_scope_buffer) {
		env = CAR(x);
        treenv_bind (TREENV_SYMBOLS(env), TREENV_BINDINGS(env));
	}

	tregc_pop ();
	trelist_free_toplevel (treenv_scope_buffer);
	treenv_scope_buffer = treptr_nil;
}

/* Unbind parent environments until one matches 'parent'. */
void
treenv_unbind_env (treptr env, treptr parent)
{
    RETURN_IF_NIL(env);
    RETURN_IF_NIL(TREENV_PARENT(env));

    for (env = TREENV_PARENT(env); env != treptr_nil && env != parent; env = TREENV_PARENT(env))
        treenv_unbind (TREENV_SYMBOLS(env));
}
