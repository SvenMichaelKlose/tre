/*
 * tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include <stdio.h>

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "builtin.h"
#include "special.h"
#include "gc.h"
#include "print.h"
#include "debug.h"
#include "thread.h"
#include "env.h"
#include "argument.h"
#include "string2.h"
#include "xxx.h"
#include "apply.h"

treptr treopt_verbose_eval;
treptr treeval_slot_value;
treptr treeval_function_symbol;

unsigned treeval_recursions;

treptr
treeval_funcall (treptr func, treptr args, bool do_argeval)
{
    treptr  funcdef;
    treptr  expforms;
    treptr  expvals;
    treptr  ret;
    treptr  argdef;
    treptr  body;
    treptr  env;
    treptr  env_parent;
    treptr  old_parent;

    funcdef = TREATOM_VALUE(func);
    argdef = CAR(funcdef);
    body = CDR(funcdef);

    env = (treptr) (size_t) TREATOM_DETAIL(func);
    env_parent = TRECONTEXT_ENV_CURRENT();
    TRECONTEXT_ENV_CURRENT() = env;
    old_parent = env_parent;

    trearg_expand (&expforms, &expvals, argdef, args, do_argeval);
    tregc_push (expforms);
    tregc_push (expvals);

    treenv_bind (expforms, expvals);

    ret = treeval_list (body);
    tregc_retval (ret);

    treenv_unbind (expforms);
    TRECONTEXT_ENV_CURRENT() = old_parent;

    tregc_pop ();
    tregc_pop ();
    TRELIST_FREE_TOPLEVEL_EARLY(expvals);
    TRELIST_FREE_TOPLEVEL_EARLY(expforms);

    return ret;
}

treptr
treeval_xlat_function (treevalfunc_t *xlat, treptr func, treptr args, bool do_argeval)
{
    treptr  evaldargs;
    treptr  ret;

    evaldargs = (do_argeval) ? treeval_args (args) : trelist_copy (args);
    tregc_push (evaldargs);

    ret = xlat[(size_t) TREATOM_DETAIL(func)] (evaldargs);
    tregc_retval (ret);

    tregc_pop ();
    TRELIST_FREE_TOPLEVEL_EARLY(evaldargs);

    return ret;
}

treptr
treeval_expr (treptr x)
{
    treptr  fun;
    treptr  args;
    treptr  v = treptr_invalid;

    fun = CAR(x);
    args = CDR(x);

    tredebug_chk_breakpoints (x);
	TREDEBUG_STEP();

    fun = TREPTR_TYPE(fun) == TRETYPE_SYMBOL ? TREATOM_FUN(fun) : treeval (fun);

	if (IS_COMPILED_FUN(fun))
		return trefuncall_compiled (fun, args, TRUE);

    tregc_push (fun);
    switch (TREPTR_TYPE(fun)) {
        case TRETYPE_FUNCTION:    v = treeval_funcall (fun, args, TRUE); break;
        case TRETYPE_ARRAY:       v = trefuncall_compiled (fun, args, TRUE); break;
        case TRETYPE_USERSPECIAL: v = treeval_funcall (fun, args, FALSE); break;
        case TRETYPE_BUILTIN:     v = trebuiltin (fun, args); break;
        case TRETYPE_SPECIAL:     v = trespecial (fun, args); break;
        default:                  treerror_norecover (CAR(x), "function expected instead of %s",
                                                              treerror_typename (TREPTR_TYPE(CAR(x))));
    }
    tredebug_chk_next ();
    tregc_pop ();

    return v;
}

treptr
treeval (treptr x)
{
    treptr val = x;

    RETURN_NIL(x);

#ifdef TRE_VERBOSE_EVAL
	treprint (x);
    fflush (stdout);
#endif

    tregc_push (x);
    trethread_push_call (x);

    switch (TREPTR_TYPE(x)) {
        case TRETYPE_CONS:   val = treeval_expr (x); break;
        case TRETYPE_SYMBOL: val = TREATOM_VALUE(x); break;
    }

    tregc_retval (val);
    trethread_pop_call ();
    tregc_pop ();

    return val;
}

treptr
treeval_list (treptr x)
{
    treptr res = treptr_nil;

    DOLIST (x, x) {
        res = treeval (CAR(x));
        TREEVAL_RETURN_JUMP(res);
    }

    return res;
}

treptr
treeval_args (treptr x)
{
    treptr  car;
    treptr  cdr;
    treptr  val;

    RETURN_NIL(x);

    if (x == tre_atom_rest || x == tre_atom_body)
		return x;

    tregc_push (x);
    car = treeval (CAR(x));
    tregc_push (car);
    cdr = treeval_args (CDR(x));
    val = CONS(car, cdr);
    tregc_pop ();
    tregc_pop ();

    return val;
}

void
treeval_init ()
{
	treeval_recursions = 0;

    treeval_slot_value = treatom_get ("%SLOT-VALUE", TRECONTEXT_PACKAGE());
	EXPAND_UNIVERSE(treeval_slot_value);
    treeval_function_symbol = treatom_get ("FUNCTION", TRECONTEXT_PACKAGE());
	EXPAND_UNIVERSE(treeval_function_symbol);

    treopt_verbose_eval = treatom_get ("*VERBOSE-EVAL*", TRECONTEXT_PACKAGE());
    treatom_set_value (treopt_verbose_eval, treptr_nil);
	EXPAND_UNIVERSE(treopt_verbose_eval);
}

#endif /* #ifdef INTERPRETER */
