/*
 * TRE interpreter
 * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 *
 * Evaluation related section.
 *
 * Function arguments are saved on the GC stack to avoid accidential
 * removal. Functions called from this section must copy argument lists
 * since they're removed if an eval function returns.
 */

#include "config.h"
#include "atom.h"
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
#include "diag.h"

#include <stdio.h>

treptr treopt_verbose_eval;
treptr treeval_slot_value;
treptr treeval_function_symbol;

/*
 * Execute user-defined function.
 *
 * 'func'        Pointer to function atom. Its value is the table index.
 * 'expr'        Expression to evaluate.
 * 'do_argeval'  If not 0 all arguments are evaluated.
 */
treptr
treeval_funcall (treptr func, treptr expr, bool do_argeval)
{
    treptr  args;		/* Arguments; second to last expression element. */
    treptr  funcdef;	/* Function definition tree. */
    treptr  expforms;	/* Expanded argument forms. */
    treptr  expvals;    /* Expanded argument values. */
    treptr  ret;		/* Function return value. */
    treptr  forms;		/* Unexpanded argument definition. */
    treptr  body;		/* Function body. */
    treptr  env;
    treptr  env_parent;
    treptr  old_parent;
#ifdef TRE_DIAGNOSTICS
    treptr funstack = TRECONTEXT_FUNSTACK();
#endif

    args = CDR(expr);
    funcdef = TREATOM_VALUE(func);
    forms = CAR(funcdef);
    body = CDR(funcdef);

    /* Switch to new environment. */
    env = (treptr) TREATOM_DETAIL(func);
    env_parent = TRECONTEXT_ENV_CURRENT();
    TRECONTEXT_ENV_CURRENT() = env;
    old_parent = env_parent;

    /* Expand argument keywords. */
    trearg_expand (&expforms, &expvals, forms, args, do_argeval);
    tregc_push (CONS(expforms, expvals));

    /* Bind arguments. */
    treenv_bind (expforms, expvals);

    /* Evaluate body. */
    ret = treeval_list (body);
    tregc_retval (ret);

    /* Restore former environment. */
    treenv_unbind (expforms);
    TRECONTEXT_ENV_CURRENT() = old_parent;

    /* Free argument list. */
    tregc_pop ();
    TRELIST_FREE_TOPLEVEL_EARLY(expvals);
    TRELIST_FREE_TOPLEVEL_EARLY(expforms);

#ifdef TRE_DIAGNOSTICS
    if (funstack != TRECONTEXT_FUNSTACK())
		treerror_internal (treptr_invalid, "function stack corrupted");
#endif

    return ret;
}

treptr
treeval_function (treptr expr)
{
    treptr  args;		/* Arguments; second to last expression element. */
    treptr  funcdef;	/* Function definition tree. */
    treptr  expforms;	/* Expanded argument forms. */
    treptr  expvals;    /* Expanded argument values. */
    treptr  ret;		/* Function return value. */
    treptr  forms;		/* Unexpanded argument definition. */
    treptr  body;		/* Function body. */

    args = CDR(expr);
    funcdef = CADAR(expr);
    forms = CAR(funcdef);
    body = CDR(funcdef);

    /* Expand argument keywords. */
    trearg_expand (&expforms, &expvals, forms, args, TRUE);
    tregc_push (CONS(expforms, expvals));

    /* Bind arguments. */
    treenv_bind (expforms, expvals);

    /* Evaluate body. */
    ret = treeval_list (body);
    tregc_retval (ret);

	/* Restore argument symbol values. */
    treenv_unbind (expforms);

    /* Free argument list. */
    tregc_pop ();
    TRELIST_FREE_TOPLEVEL_EARLY(expvals);
    TRELIST_FREE_TOPLEVEL_EARLY(expforms);

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
treptr
treeval_xlat_function (treevalfunc_t *xlat, treptr func, treptr expr,
			bool do_argeval)
{
    treptr  args = CDR(expr);
    treptr  evaldargs;
    treptr  ret;
#ifdef TRE_DIAGNOSTICS
    treptr funstack = TRECONTEXT_FUNSTACK();
#endif

    /* Evaluate arguments. */
    evaldargs = (do_argeval) ?
        treeval_args (args) :
        trelist_copy (args);
    tregc_push (evaldargs);

    /* Call internal function. */
    ret = xlat[(ulong) TREATOM_DETAIL(func)] (evaldargs);
    tregc_retval (ret);

    /* Free internal garbage immediately. */
    tregc_pop ();
    TRELIST_FREE_TOPLEVEL_EARLY(evaldargs);

#ifdef TRE_DIAGNOSTICS
    if (funstack != TRECONTEXT_FUNSTACK())
		treerror_internal (treptr_invalid, "function stack corrupted");
#endif

    return ret;
}

/*
 * Evaluate expression
 *
 * Does a function call. The first argument of the list must be a function
 * atom.
 */
treptr
treeval_expr (treptr x)
{
    treptr  fun;
    treptr  v;
    treptr  slot_obj;
	bool	copied_expr = FALSE;

    fun = CAR(x);
    v = treptr_nil;

    tredebug_chk_breakpoints (x);
	TREDEBUG_STEP();

	/* Get function value of variable immediately. */
	switch (TREPTR_TYPE(fun)) {
		case TRETYPE_VARIABLE:
        	fun = TREATOM_FUN(fun);
			break;

		case TRETYPE_CONS:
			if (CAR(fun) == treeval_slot_value) {
				slot_obj = CAR(CDR(fun));
       			fun = treeval (fun);
   				tregc_push (fun);
				x = CONS(CAR(x),
			 			CONS(slot_obj,
				  			trelist_copy (CDR(x))));
				tregc_push (x);
				copied_expr = TRUE;
				break;
			} else if (CAR(fun) == treeval_function_symbol
						&& TREPTR_IS_CONS(CDR(fun))
						&& TREPTR_IS_CONS(CADR(fun))
						&& CDDR(fun) == treptr_nil)
				return treeval_function (x);

		default:
        	fun = treeval (fun);
	}

    tregc_push (fun);

    switch (TREPTR_TYPE(fun)) {
        case TRETYPE_FUNCTION:
            v = treeval_funcall (fun, x, TRUE);
            break;

        case TRETYPE_USERSPECIAL:
            v = treeval_funcall (fun, x, FALSE);
            break;

        case TRETYPE_BUILTIN:
            v = trebuiltin (fun, x);
            break;

        case TRETYPE_SPECIAL:
            v = trespecial (fun, x);
            break;

        default:
            return treerror (CAR(x), "function expected instead of %s",
                             treerror_typename (TREPTR_TYPE(CAR(x))));
    }

    tredebug_chk_next ();

    tregc_pop ();
	if (copied_expr) {
    	tregc_pop ();
    	tregc_pop ();
	}

    return v;
}

/*
 * Evaluate an expression or atom.
 */
treptr
treeval (treptr x)
{
    treptr val = x;

	CHKPTR(x);
#ifdef TRE_DIAGNOSTICS
    treptr gcss = tregc_save_stack;
#endif

    RETURN_NIL(x);

#ifdef TRE_VERBOSE_EVAL
    if (TREATOM_VALUE(treopt_verbose_eval) != treptr_nil)
		treprint (x);
#endif

    tregc_push (x);
    trethread_push_call (x);

    switch (TREPTR_TYPE(x)) {
        /* Call function, special form or macro. */
        case TRETYPE_CONS:
            val = treeval_expr (x);
            break;

        /* Return variable value. */
        case TRETYPE_VARIABLE:
            val = TREATOM_VALUE(x);
            break;

#ifdef TRE_DIAGNOSTICS
        /* Return constants as they are. */
        case TRETYPE_NUMBER:
        case TRETYPE_STRING:
        case TRETYPE_ARRAY:
        case TRETYPE_FUNCTION:
        case TRETYPE_USERSPECIAL:
        case TRETYPE_BUILTIN:
        case TRETYPE_SPECIAL:
        case TRETYPE_MACRO:
            break;

        /* Cough, if we don't know the atom type. */
        default:
            treerror_internal (x, "invalid atom type");
#endif
    }

    tregc_retval (val);
    trethread_pop_call ();
    tregc_pop ();

#ifdef TRE_DIAGNOSTICS
    if (gcss != tregc_save_stack)
		treerror_internal (x, "GC stack corrupted");
#endif

    return val;
}

/*
 * Evaluate expressions in list and return value of the last.
 */
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

/*
 * Evaluate list atom-wise.
 */
treptr
treeval_args (treptr x)
{
    treptr  car;
    treptr  cdr;
    treptr  val;

    RETURN_NIL(x);

    if (x == tre_atom_rest)
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
    treeval_slot_value = treatom_get ("%SLOT-VALUE", TRECONTEXT_PACKAGE());
	EXPAND_UNIVERSE(treeval_slot_value);
    treeval_function_symbol = treatom_get ("FUNCTION", TRECONTEXT_PACKAGE());
	EXPAND_UNIVERSE(treeval_function_symbol);

    treopt_verbose_eval = treatom_get ("*VERBOSE-EVAL*", TRECONTEXT_PACKAGE());
    treatom_set_value (treopt_verbose_eval, treptr_nil);
	EXPAND_UNIVERSE(treopt_verbose_eval);
}
