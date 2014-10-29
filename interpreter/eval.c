/*
 * tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
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
#include "argument.h"
#include "string2.h"
#include "xxx.h"
#include "funcall.h"
#include "symtab.h"
#include "function.h"
#include "backtrace.h"
#include "thread.h"
#include "symbol.h"

treptr treopt_verbose_eval;
treptr eval_slot_value;
treptr eval_function_symbol;

unsigned eval_recursions;

treptr
eval_bind (treptr la, treptr lv)
{
    treptr  sym;
    treptr  old = NIL;

    while (NOT_NIL(la) && NOT_NIL(lv)) {
        tregc_push (old);
        sym = CAR(la);
        old = CONS(CONS(sym, SYMBOL_VALUE(sym)), old);
		SYMBOL_VALUE(sym) = CAR(lv);
        tregc_pop ();

        la = CDR(la);
        lv = CDR(lv);
    }

    if (NOT_NIL(la))
        treerror (la, "Arguments missing.");
    if (NOT_NIL(lv))
        treerror (lv, "Too many arguments.");

    return old;
}

void
eval_unbind (treptr old)
{
    treptr  v;

    while (NOT_NIL(old)) {
        v = CAR(old);
        SYMBOL_VALUE(CAR(v)) = CDR(v);
        old = CDR(old);
    }
}

treptr
eval_funcall_raw (treptr funcdef, treptr args, bool do_argeval)
{
    treptr  expforms;
    treptr  expvals;
    treptr  ret;
    treptr  argdef;
    treptr  body;
    treptr  old_bindings;

    argdef = CAR(funcdef);
    body = CDR(funcdef);

    trearg_expand (&expforms, &expvals, argdef, args, do_argeval);
    tregc_push (expforms);
    tregc_push (expvals);

    old_bindings = eval_bind (expforms, expvals);
    tregc_push (old_bindings);

    ret = eval_list (body);

    tregc_pop ();
    eval_unbind (old_bindings);

    tregc_pop ();
    tregc_pop ();

    return ret;
}


treptr
eval_funcall (treptr func, treptr args, bool do_argeval)
{
    return eval_funcall_raw (FUNCTION_SOURCE(func), args, do_argeval);
}

treptr
eval_xlat_function (evalfunc_t *xlat, treptr func, treptr args, bool do_argeval)
{
    treptr  evaldargs;
    treptr  ret;

    evaldargs = (do_argeval) ? eval_args (args) : args;
    tregc_push (evaldargs);

    ret = xlat[(size_t) ATOM(func)] (evaldargs);

    tregc_pop ();

    return ret;
}

#define FUNCTIONEXPRP(x) \
    (CONSP(x) && CONSP(_CDR(x)) && CONSP(_CADR(x)) && _CAR(x) == atom_function)

treptr
eval_expr (treptr x)
{
    treptr  first;
    treptr  args;
    treptr  fun;
    treptr  v = treptr_invalid;

    first = CAR(x);
    args = CDR(x);

    if (SYMBOLP(first))
        fun = SYMBOL_FUNCTION(first);
    else if (FUNCTIONEXPRP(first))
        return eval_funcall_raw (_CADR(first), args, TRUE);
    else
        fun = eval (first);

	if (COMPILED_FUNCTIONP(fun) || ARRAYP(fun))
		return funcall_compiled (fun, args, TRUE);

    trebacktrace_push ((BUILTINP(fun) || SPECIALP(fun)) ? fun : FUNCTION_NAME(fun));

    switch (TREPTR_TYPE(fun)) {
        case TRETYPE_FUNCTION:    v = eval_funcall (fun, args, TRUE); break;
        case TRETYPE_USERSPECIAL: v = eval_funcall (fun, args, FALSE); break;
        case TRETYPE_BUILTIN:     v = trebuiltin (fun, args); break;
        case TRETYPE_SPECIAL:     v = trespecial (fun, args); break;
        default:
            treerror_norecover (CAR(x), "Function expected instead of %s.",
                                        treptr_typename (CAR(x)));
    }

    trebacktrace_pop ();

    return v;
}

treptr
eval (treptr x)
{
    treptr val = x;

    RETURN_NIL(x);

    tregc_push (x);

    switch (TREPTR_TYPE(x)) {
        case TRETYPE_CONS:   val = eval_expr (x); break;
        case TRETYPE_SYMBOL: val = SYMBOL_VALUE(x); break;
    }

    tregc_pop ();

    return val;
}

treptr
eval_list (treptr x)
{
    treptr res = NIL;

    DOLIST (x, x) {
        res = eval (CAR(x));
        TREEVAL_RETURN_JUMP(res);
    }

    return res;
}

treptr
eval_args (treptr x)
{
    treptr  a;
    treptr  d;
    treptr  val;

    RETURN_NIL(x);

    if (x == tre_atom_rest || x == tre_atom_body)
		return x;

    tregc_push (x);
    a = eval (CAR(x));
    tregc_push (a);
    d = eval_args (CDR(x));
    val = CONS(a, d);
    tregc_pop ();
    tregc_pop ();

    return val;
}

void
eval_init ()
{
	eval_recursions = 0;

    eval_slot_value = symbol_get ("%SLOT-VALUE");
	EXPAND_UNIVERSE(eval_slot_value);
    eval_function_symbol = symbol_get ("FUNCTION");
	EXPAND_UNIVERSE(eval_function_symbol);

    treopt_verbose_eval = symbol_get ("*VERBOSE-EVAL*");
    SYMBOL_VALUE(treopt_verbose_eval) = NIL;
	EXPAND_UNIVERSE(treopt_verbose_eval);
}

#endif /* #ifdef INTERPRETER */
