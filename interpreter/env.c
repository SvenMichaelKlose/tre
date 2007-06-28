/*
 * nix operating system project lisp interpreter
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

#include "lisp.h"
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
lispenv_create (lispptr a)
{
    LISPATOM_DETAIL(a) = (void *) 
        CONS(LISPCONTEXT_ENV_CURRENT(), CONS(lispptr_nil, lispptr_nil));
}
/* Update bindings of environment. */
void
lispenv_update (lispptr env, lispptr atoms, lispptr values)
{
    RETURN_IF_NIL(env);
    LISPENV_SET_SYMBOLS(env, lisplist_copy (atoms));
    LISPENV_SET_BINDINGS(env, lisplist_copy (values));
}
   
/*
 * Argument bindings
 */

/* Bind argument list to atoms. */
void
lispenv_bind (lispptr la, lispptr lv)
{
    struct lisp_atom *atom;
    lispptr  arg;
    lispptr  val;

    for (;la != lispptr_nil && lv != lispptr_nil; la = CDR(la), lv = CDR(lv)) {
        arg = CAR(la);
        val = CAR(lv);
#ifdef LISP_DIAGNOSTICS
        if (LISPPTR_IS_VARIABLE(arg) == FALSE)
            lisperror_internal (arg, "bind: variable expected");
#endif

    	atom = LISPPTR_TO_ATOM(arg);
        atom->binding = CONS(atom->value, atom->binding);
        atom->value = val;
    }

    if (la != lispptr_nil)
        lisperror (la, "arguments missing");
    if (lv != lispptr_nil)
        lisperror (lv, "too many arguments. Rest of forms");
}

/*
 * Argument bindings
 */

/* Bind argument list to atoms. Stop if the shorter list ends. */
void
lispenv_bind_sloppy (lispptr la, lispptr lv)
{
    struct lisp_atom *atom;
    lispptr  car;
    
    while (la != lispptr_nil) {
        car = CAR(la);
#ifdef LISP_DIAGNOSTICS
        if (LISPPTR_IS_VARIABLE(car) == FALSE)
            lisperror_internal (car, "sloppy bind: variable expexted");
#endif  
        
        /* Push value on binding list. */
        atom = LISPPTR_TO_ATOM(car); 
        atom->binding = CONS(atom->value, atom->binding);
        if (lv != lispptr_nil)
            atom->value = CAR(lv);
        else
            atom->value = lispptr_nil;
        
        la = CDR(la);
        if (lv != lispptr_nil)
            lv = CDR(lv);
    }
}

/* Unbind argument list from atoms. */
void
lispenv_unbind (lispptr la)
{
    struct lisp_atom  *atom;
    lispptr  bding;

    for (;la != lispptr_nil; la = CDR(la)) {
        atom = LISPPTR_TO_ATOM(CAR(la));
        bding = atom->binding; 
        atom->value = CAR(bding);
        atom->binding = CDR(bding);
        LISPLIST_FREE_EARLY(bding);
    }
}

/*
 * Environment bindings
 */

/* Bind parent environments until one matches 'parent'. */
void
lispenv_bind_env (lispptr env, lispptr parent)
{
    RETURN_IF_NIL(env);
    RETURN_IF_NIL(LISPENV_PARENT(env));

    for (env = LISPENV_PARENT(env); env != lispptr_nil && env != parent; env = LISPENV_PARENT(env))
        lispenv_bind (LISPENV_SYMBOLS(env), LISPENV_BINDINGS(env));
}

/* Unbind parent environments until one matches 'parent'. */
void
lispenv_unbind_env (lispptr env, lispptr parent)
{
    RETURN_IF_NIL(env);
    RETURN_IF_NIL(LISPENV_PARENT(env));

    for (env = LISPENV_PARENT(env); env != lispptr_nil && env != parent; env = LISPENV_PARENT(env))
        lispenv_unbind (LISPENV_SYMBOLS(env));
}
