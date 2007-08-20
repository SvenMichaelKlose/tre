/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in special forms.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "special.h"
#include "error.h"
#include "gc.h"
#include "debug.h"
#include "thread.h"
#include "env.h"
#include "argument.h"

#include "builtin_debug.h"
#include "builtin_atom.h"

treptr tre_atom_evaluated_go;
treptr tre_atom_evaluated_return_from;

/* Test if expression is an evaluated RETURN-FROM. */
bool
treeval_is_return (treptr p)
{
    if (TREPTR_IS_EXPR(p) == FALSE)
	return FALSE;

    return CAR(p) == tre_atom_evaluated_return_from;
}

/* Test if expression is an evaluated GO. */
bool
treeval_is_go (treptr p)
{
    if (TREPTR_IS_EXPR(p) == FALSE)
	return FALSE;

    return CAR(p) == tre_atom_evaluated_go;
}

/* Test if expression is an evaluated GO or RETURN-FROM. */
bool
treeval_is_jump (treptr p)
{
    return treeval_is_return (p) || treeval_is_go (p);
}

/*
 * (SETQ {symbol value}*)
 *
 * Assign quoted value to variable.
 */
treptr
trespecial_setq (treptr list)
{
    struct tre_atom *atom;
    treptr car;
    treptr cdr;
    treptr tmp;

    /* Check if there're any arguments. */
    if (list == treptr_nil)
	return treerror (treptr_nil, "arguments expected");

    do {
        /* Check arguments. */
        car = CAR(list);
        atom = TREPTR_TO_ATOM(car);

        list = CDR(list);
        if (list == treptr_nil)
	    return treerror (list, "even number arguments expected");

	/* Evaluate value expression. */
        tmp = CDR(list);
        cdr = treeval (CAR(list));
        list = tmp;

	/* Catch RETURN-FROM. */
	TREEVAL_RETURN_JUMP(cdr);

	if (TREPTR_TYPE(car) == ATOM_VARIABLE)
            treatom_set_value (car, cdr);
        else
	    return treerror (car, "variable expected");

	/* Step to next pair. */
    } while (list != treptr_nil);

    return cdr;
}

/*
 * (MACRO symbol-list body)
 *
 * Return user defined special form.
 */
treptr
trespecial_macro (treptr list)
{
    treptr  f;
    treptr  expr = trelist_copy (list);

    trearg_apply_keyword_package (CAR(expr));
    f = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), ATOM_MACRO, expr);
    treenv_create (f);

    return f;
}

/*
 * (MACRO symbol-list body)
 *
 * Return user defined special form.
 */
treptr
trespecial_special (treptr list)
{
    treptr  expr = trelist_copy (list);
    treptr  ret;

    trearg_apply_keyword_package (CAR(expr));

    /* Create macro atom. */
    tregc_push (expr);
    ret = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), ATOM_USERSPECIAL, expr);
    tregc_pop ();

    return ret;
}

/*
 *  (COND (test expression-list)*)
 *
 *  Evaluates test-expression pairs in order. If a test returns non-NIL,
 *  the expression is evaluated and returned. If no test matches NIL is
 *  returned.
 */
treptr
trespecial_cond (treptr p)
{
    treptr pair;
    treptr test;
    treptr body;

    if (TREPTR_IS_EXPR(p) == FALSE)
	return treerror (p, "expression expected");

    for (;p != treptr_nil; p = CDR(p)) {
	pair = CAR(p);
	if (p == treptr_nil || TREPTR_IS_ATOM(p))
	    return treerror (p, "test/expression pair expected");

	test = CAR(pair);
	body = CDR(pair);
	if (treeval (test) != treptr_nil)
	    return treeval_list (body);
    }

    return treptr_nil;
}

/*
 * (QUOTE expression)
 *
 * Returns expression unevaluated. The short form "'", preceding
 * symbols and expressions, may be used.
 */
treptr
trespecial_quote (treptr list)
{
    if (list == treptr_nil)
        treerror (treptr_nil, "argument expected");
    return CAR(list);
}

/*
 * (PROGN expression*)
 *
 * Evaluates expressions and returns the value of the last.
 */
treptr
trespecial_progn (treptr list)
{
    treptr last;

    for (last = treptr_nil; list != treptr_nil; list = CDR(list)) {
	last = treeval (CAR(list));
	TREEVAL_RETURN_JUMP(last);
    }

    return last;
}

/*
 * (BLOCK symbol expression*)
 *
 * Evaluates expression by expression and returns the last.
 * On evaluation of RETURN-FROM inside the body, evaluation of the
 * block is terminated.
 */
treptr
trespecial_block (treptr args)
{
    treptr tag;
    treptr p;
    treptr last = treptr_nil;

    tag = CAR(args);
    if (TREPTR_IS_EXPR(tag))
	return treerror (tag, "tag expected instead of an expression");

    p = CDR(args);
    if (p == treptr_nil)
	return treptr_nil;

    while (p != treptr_nil) {
	last = treeval (CAR(p));

	if (!treeval_is_return (last)) {
            p = CDR(p);
	    continue;
        }

        if (tag != CADR(last))
	    return last;

        p = CADDR(last);
	TRELIST_FREE_EARLY(CDR(last));
	TRELIST_FREE_EARLY(last);
        /* XXX more to free of return expression? */
	return p;
    }

    return last;
}

/*
 * (RETURN-FROM tag expression)
 *
 * Exit BLOCK named tag and return the evaluated expression.
 */
treptr
trespecial_return_from (treptr args)
{
    treptr tmp;
    treptr ret;

    /* Check arguments. */
    if (args == treptr_nil)
	return treerror (treptr_invalid, "tag and expression expected");
    if (CDR(args) == treptr_nil)
	return treerror (treptr_invalid, "expression missing after tag");
    if (CDDR(args) != treptr_nil)
	return treerror (CDDR(args), "only two args expected");

    /* Evaluate expression for return value. */
    args = trelist_copy (args);
    tregc_push (args);

    tmp = CDR(args);
    RPLACA(tmp, treeval (CAR(tmp)));
    ret = CONS(tre_atom_evaluated_return_from, args);

    tregc_pop ();
    return ret;
}

/*
 * (TAGBODY {tag | expression} *)
 *
 * Evaluates expression by expression and returns NIL. Tags are
 * ignored.
 * On evaluation of GO inside the body, evaluation is continued
 * after the tag specified.
 */
treptr
trespecial_tagbody (treptr body)
{
    treptr res = treptr_nil;
    treptr tag;
    treptr p;
    treptr car;

    p = body;
    while (1) {
tag_found:
	/* Return on end of list. */
	if (p == treptr_nil)
	    break;

        /* Evaluate expression, skip non-expression. */
	car = CAR(p);
	if (TREPTR_IS_EXPR(car) == FALSE)
            goto next;

        res = treeval (car);

        /* Pass through RETURN-FROM for BLOCK. */
        if (treeval_is_return (res))
            return res;

        /* Continue to next if expression didn't return a GO expression. */
	if (!treeval_is_go (res))
            goto next;

	/* We have a GO. Continue after occurence of the tag. */
        tag = CDR(res);
	DOLIST(p, body) {
	    if (CAR(p) != tag)
		continue;

	    p = CDR(p);
	    TRELIST_FREE_EARLY(res);
	    goto tag_found;
	}

	return res;

next:
        p = CDR(p);
    }

    return treptr_nil;
}

/*
 * (GO tag)
 *
 * Inside a TAGBODY, continue evaluation at tag.
 */
treptr
trespecial_go (treptr args)
{
    return CONS(tre_atom_evaluated_go, trearg_get (args));
}

/*
 * (FUNCTION var | lambda-expression)
 *
 * Return function atom referred to by a variable's function pointer or
 * create one from a LAMBDA expression.
 */
treptr
trespecial_function (treptr fun)
{
    treptr car;
    treptr f;
    treptr args_body;

    if (fun == treptr_nil)
	return treerror (fun, "function name expected");
    if (CDR(fun) != treptr_nil)
	return treerror (fun, "single argument expected");

    car = CAR(fun);

    switch (TREPTR_TYPE(car)) {
        case ATOM_EXPR:
	    break;

        case ATOM_VARIABLE:
            return TREATOM_FUN(car);

        case ATOM_FUNCTION:
        case ATOM_BUILTIN:
        case ATOM_SPECIAL:
	    return car;

        default:
	    goto no_fun;
    }

    if (TREPTR_IS_ATOM(CAR(car)) && CAR(car) != treatom_lambda)
        goto no_fun;

    args_body = TREPTR_IS_EXPR(CAR(car)) ?  car : CDR(car);
    if (args_body == treptr_nil)
        return treerror (fun, "argument list and body missing");

    args_body = trelist_copy (args_body);
    tregc_push (args_body);

    trearg_apply_keyword_package (CAR(args_body));
    f = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), ATOM_FUNCTION, args_body);
    tregc_retval (f);
    treenv_create (f);

    tregc_pop ();
    return f;

no_fun:
    return treerror (car, "function or argument/body pair expected");
}

char *tre_special_names[] = {
    "SETQ",

    "MACRO", "SPECIAL",

    "COND",

    "QUOTE",

    "PROGN",

    "BLOCK", "RETURN-FROM", "TAGBODY", "GO",

    "FUNCTION",

    "%SET-ATOM-FUN",

    "SET-BREAKPOINT", "REMOVE-BREAKPOINT",
    NULL
};

treevalfunc_t treeval_xlat_spec[] = {
    trespecial_setq,
    trespecial_macro,
    trespecial_special,
    trespecial_cond,
    trespecial_quote,
    trespecial_progn,
    trespecial_block,
    trespecial_return_from,
    trespecial_tagbody,
    trespecial_go,
    trespecial_function,
    treatom_builtin_set_atom_fun,
    tredebug_builtin_set_breakpoint,
    tredebug_builtin_remove_breakpoint,
    NULL
};

/*
 * Call built-in special operator
 */
treptr
trespecial (treptr func, treptr expr)
{
    return treeval_xlat_function (treeval_xlat_spec, func, expr, FALSE);
}

void
trespecial_init ()
{
    tre_atom_evaluated_go
        = treatom_get ("%%EVALD-GO", TRECONTEXT_PACKAGE());
    tre_atom_evaluated_return_from
        = treatom_get ("%%EVALD-RETURN-FROM", TRECONTEXT_PACKAGE());
    treatom_lambda
        = treatom_get ("LAMBDA", TRECONTEXT_PACKAGE());

    EXPAND_UNIVERSE(treatom_lambda);
}
