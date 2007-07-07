/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Evaluation related section.
 *
 * Function arguments are saved on the GC stack to avoid accidential
 * removal. Functions called from this section must copy argument lists
 * since they're removed if an eval function returns.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "builtin.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "special.h"
#include "gc.h"
#include "print.h"
#include "debug.h"
#include "thread.h"
#include "env.h"
#include "argument.h"
#include "string.h"
#include "xxx.h"

#include <stdio.h>

lispptr lispopt_verbose_eval;

/*
 * Execute user-defined function.
 *
 * 'func'        Pointer to function atom. Its value is the table index.
 * 'expr'        Expression to evaluate.
 * 'do_argeval'  If not 0 all arguments are evaluated.
 */
lispptr
lispeval_funcall (lispptr func, lispptr expr, bool do_argeval)
{
    lispptr  args;	/* Arguments; second to last expression element. */
    lispptr  funcdef;	/* Function definition tree. */
    lispptr  expforms;	/* Expanded argument forms. */
    lispptr  expvals;   /* Expanded argument values. */
    lispptr  ret;	/* Function return value. */
    lispptr  forms;	/* Unexpanded argument definition. */
    lispptr  body;	/* Function body. */
    lispptr  env;
    lispptr  env_parent;
    lispptr  old_parent;
#ifdef LISP_DIAGNOSTICS
    lispptr funstack = LISPCONTEXT_FUNSTACK();
#endif

    args = CDR(expr);
    funcdef = LISPATOM_VALUE(func);
    forms = CAR(funcdef);
    body = CDR(funcdef);

    /* Switch to new environment. */
    env = (lispptr) LISPATOM_DETAIL(func);
    env_parent = LISPCONTEXT_ENV_CURRENT();
    LISPCONTEXT_ENV_CURRENT() = env;
    old_parent = env_parent;
    while (env == env_parent) {
        if (!env_parent)
	    break;
        env_parent = LISPENV_PARENT(env_parent);
    }

    /* Expand argument keywords. */
    lisparg_expand (&expforms, &expvals, forms, args, do_argeval);
    lispgc_push (expforms);
    lispgc_push (expvals);

    /* Prepare environment. */
    if (do_argeval) {
        /* Bind new parent environments. */
        lispenv_bind_env (env, env_parent);

        /* Update function's environment. */
        lispenv_update (env, expforms, expvals);
    }

    /* Bind arguments. */
    lispenv_bind (expforms, expvals);

    /* Evaluate body. */
    ret = lispeval_list (body);
    lispgc_retval (ret);

    /* Restore former environment. */
    lispenv_unbind (expforms);
    if (do_argeval)
        lispenv_unbind_env (env, env_parent);
    LISPCONTEXT_ENV_CURRENT() = old_parent;

    /* Free argument list. */
    lispgc_pop ();
    LISPLIST_FREE_TOPLEVEL_EARLY(expvals);
    lispgc_pop ();
    LISPLIST_FREE_TOPLEVEL_EARLY(expforms);

#ifdef LISP_DIAGNOSTICS
    if (funstack != LISPCONTEXT_FUNSTACK())
	lisperror_internal (lispptr_invalid, "function stack corrupted");
#endif

    return ret;
}

/*
 * Execute built-in function.
 *
 * 'xlat'        C function table.
 * 'func'        Pointer to function atom. Its value is the table index.
 * 'expr'        Expression to evaluate.
 * 'do_argeval'  If not 0 all arguments are evaluated.
 *
 * Built-in functions have no environment.
 */
lispptr
lispeval_xlat_function (lispevalfunc_t *xlat, lispptr func, lispptr expr,
			bool do_argeval)
{
    lispptr  args = CDR(expr);
    lispptr  evaldargs;
    lispptr  ret;
#ifdef LISP_DIAGNOSTICS
    lispptr funstack = LISPCONTEXT_FUNSTACK();
#endif

    /* Evaluate arguments. */
    evaldargs = (do_argeval) ?
        lispeval_args (args) :
        lisplist_copy (args);
    lispgc_push (evaldargs);

    /* Call internal function. */
    ret = xlat[(int) LISPATOM_DETAIL(func)] (evaldargs);
    lispgc_retval (ret);

    /* Free internal garbage immediately. */
    lispgc_pop ();
    LISPLIST_FREE_TOPLEVEL_EARLY(evaldargs);

#ifdef LISP_DIAGNOSTICS
    if (funstack != LISPCONTEXT_FUNSTACK())
	lisperror_internal (lispptr_invalid, "function stack corrupted");
#endif

    return ret;
}

/*
 * Evaluate expression
 *
 * Does a function call. The first argument of the list must be a function
 * atom.
 */
lispptr
lispeval_expr (lispptr x)
{
    lispptr  fun = CAR(x);
    lispptr  v = lispptr_nil;

    lispdebug_chk_breakpoints (x);

    if (LISPPTR_IS_EXPR(fun))
        fun = lispeval (fun);
    if (LISPPTR_IS_VARIABLE(fun))
        fun = LISPATOM_FUN(fun);
    lispgc_push (fun);

    switch (LISPPTR_TYPE(fun)) {
        case ATOM_FUNCTION:
            v = lispeval_funcall (fun, x, TRUE);
            break;

        case ATOM_BUILTIN:
            v = lispbuiltin (fun, x);
            break;

        case ATOM_SPECIAL:
            v = lispspecial (fun, x);
            break;

        case ATOM_USERSPECIAL:
            v = lispeval_funcall (fun, x, FALSE);
            break;

        default:
            return lisperror (fun, "function expected instead of %s",
                              lisperror_typestring (fun));
    }

    lispdebug_chk_next ();

    lispgc_pop ();
    return v;
}

/*
 * Evaluate an expression or atom.
 */
lispptr
lispeval (lispptr x)
{
    lispptr val = x;

#ifdef LISP_DIAGNOSTICS
    lispptr gcss = lispgc_save_stack;
#endif

#ifdef LISP_VERBOSE_EVAL
    if (LISPATOM_VALUE(lispopt_verbose_eval) != lispptr_nil)
      lispprint (x);
#endif

    RETURN_NIL(x);

    /* Remember parent node. */
    lispthread_push_call (x);

    lispgc_push (x);

    switch (LISPPTR_TYPE(x)) {
        /* Call function, special form or macro. */
        case ATOM_EXPR:
            val = lispeval_expr (x);
            break;

        /* Return variable value. */
        case ATOM_VARIABLE:
            val = LISPATOM_VALUE(x);
            break;

#ifdef LISP_DIAGNOSTICS
        /* Return constants as they are. */
        case ATOM_NUMBER:
        case ATOM_STRING:
        case ATOM_ARRAY:
        case ATOM_FUNCTION:
        case ATOM_USERSPECIAL:
        case ATOM_BUILTIN:
        case ATOM_SPECIAL:
        case ATOM_MACRO:
            break;

    /* Cough, if we don't know the atom type. */
        default:
            lisperror_internal (x, "invalid atom type");
#endif
    }

    lispgc_retval (val);
    lispgc_pop ();

    /* Forget parent. */
    lispthread_pop_call ();

#ifdef LISP_DIAGNOSTICS
    if (gcss != lispgc_save_stack)
	lisperror_internal (x, "GC stack corrupted");
#endif

    return val;
}

/*
 * Evaluate expressions in list and return value of the last.
 */
lispptr
lispeval_list (lispptr x)
{
    lispptr res = lispptr_nil;

    DOLIST (x, x) {
        res = lispeval (CAR(x));
        LISPEVAL_RETURN_JUMP(res);
    }

    return res;
}

/*
 * Evaluate list atom-wise.
 */
lispptr
lispeval_args (lispptr x)
{
    lispptr  car;
    lispptr  cdr;
    lispptr  val;

    RETURN_NIL(x);

    if (x == lisp_atom_rest)
	return x;

    lispgc_push (x);

    car = lispeval (CAR(x));
    lispgc_push (car);
    cdr = lispeval_args (CDR(x));
    val = CONS(car, cdr);
    lispgc_pop ();

    lispgc_pop ();

    return val;
}

void
lispeval_init ()
{
    lispopt_verbose_eval = lispatom_get ("*VERBOSE-EVAL*",
                                         LISPCONTEXT_PACKAGE());
    lispatom_set_value (lispopt_verbose_eval, lispptr_nil);
}
