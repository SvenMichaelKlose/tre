/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in special forms.
 */

#include "lisp.h"
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

lispptr lisp_atom_evaluated_go;
lispptr lisp_atom_evaluated_return_from;

/* Test if expression is an evaluated RETURN-FROM. */
bool
lispeval_is_return (lispptr p)
{
    if (LISPPTR_IS_EXPR(p) == FALSE)
	return FALSE;

    return CAR(p) == lisp_atom_evaluated_return_from;
}

/* Test if expression is an evaluated GO. */
bool
lispeval_is_go (lispptr p)
{
    if (LISPPTR_IS_EXPR(p) == FALSE)
	return FALSE;

    return CAR(p) == lisp_atom_evaluated_go;
}

/* Test if expression is an evaluated GO or RETURN-FROM. */
bool
lispeval_is_jump (lispptr p)
{
    return lispeval_is_return (p) || lispeval_is_go (p);
}

/*
 * (SETQ {symbol value}*)
 *
 * Assign quoted value to variable.
 */
lispptr
lispspecial_setq (lispptr list)
{
    struct lisp_atom *atom;
    lispptr car;
    lispptr cdr;
    lispptr tmp;

    /* Check if there're any arguments. */
    if (list == lispptr_nil)
	return lisperror (lispptr_nil, "arguments expected");

    do {
        /* Check arguments. */
        car = CAR(list);
        atom = LISPPTR_TO_ATOM(car);

        list = CDR(list);
        if (list == lispptr_nil)
	    return lisperror (list, "even number arguments expected");

	/* Evaluate value expression. */
        tmp = CDR(list);
        cdr = lispeval (CAR(list));
        list = tmp;

	/* Catch RETURN-FROM. */
	LISPEVAL_RETURN_JUMP(cdr);

	if (LISPPTR_TYPE(car) == ATOM_VARIABLE)
            lispatom_set_value (car, cdr);
        else
	    return lisperror (car, "variable expected");

	/* Step to next pair. */
    } while (list != lispptr_nil);

    return cdr;
}

/*
 * (MACRO symbol-list body)
 *
 * Return user defined special form.
 */
lispptr
lispspecial_macro (lispptr list)
{
    lispptr  expr = lisplist_copy (list);

    lisparg_apply_keyword_package (CAR(expr));

    /* Create macro atom. */
    return lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_MACRO, expr);
}

/*
 * (MACRO symbol-list body)
 *
 * Return user defined special form.
 */
lispptr
lispspecial_special (lispptr list)
{
    lispptr  expr = lisplist_copy (list);
    lispptr  ret;

    lisparg_apply_keyword_package (CAR(expr));

    /* Create macro atom. */
    lispgc_push (expr);
    ret = lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_USERSPECIAL, expr);
    lispgc_pop ();

    return ret;
}

/*
 *  (COND (test expression-list)*)
 *
 *  Evaluates test-expression pairs in order. If a test returns non-NIL,
 *  the expression is evaluated and returned. If no test matches NIL is
 *  returned.
 */
lispptr
lispspecial_cond (lispptr p)
{
    lispptr pair;
    lispptr test;
    lispptr body;

    if (LISPPTR_IS_EXPR(p) == FALSE)
	return lisperror (p, "expression expected");

    for (;p != lispptr_nil; p = CDR(p)) {
	pair = CAR(p);
	if (p == lispptr_nil || LISPPTR_IS_ATOM(p))
	    return lisperror (p, "test/expression pair expected");

	test = CAR(pair);
	body = CDR(pair);
	if (lispeval (test) != lispptr_nil)
	    return lispeval_list (body);
    }

    return lispptr_nil;
}

/*
 * (QUOTE expression)
 *
 * Returns expression unevaluated. The short form "'", preceding
 * symbols and expressions, may be used.
 */
lispptr
lispspecial_quote (lispptr list)
{
    if (list == lispptr_nil)
        lisperror (lispptr_nil, "argument expected");
    return CAR(list);
}

/*
 * (PROGN expression*)
 *
 * Evaluates expressions and returns the value of the last.
 */
lispptr
lispspecial_progn (lispptr list)
{
    lispptr last;

    for (last = lispptr_nil; list != lispptr_nil; list = CDR(list)) {
	last = lispeval (CAR(list));
	LISPEVAL_RETURN_JUMP(last);
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
lispptr
lispspecial_block (lispptr args)
{
    lispptr tag;
    lispptr p;
    lispptr last = lispptr_nil;

    tag = CAR(args);
    if (LISPPTR_IS_EXPR(tag))
	return lisperror (tag, "tag expected instead of an expression");

    p = CDR(args);
    if (p == lispptr_nil)
	return lispptr_nil;

    while (p != lispptr_nil) {
	last = lispeval (CAR(p));

	if (!lispeval_is_return (last)) {
            p = CDR(p);
	    continue;
        }

        if (tag != CADR(last))
	    return last;

        p = CADDR(last);
	LISPLIST_FREE_EARLY(CDR(last));
	LISPLIST_FREE_EARLY(last);
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
lispptr
lispspecial_return_from (lispptr args)
{
    lispptr tmp;
    lispptr ret;

    /* Check arguments. */
    if (args == lispptr_nil)
	return lisperror (lispptr_invalid, "tag and expression expected");
    if (CDR(args) == lispptr_nil)
	return lisperror (lispptr_invalid, "expression missing after tag");
    if (CDDR(args) != lispptr_nil)
	return lisperror (CDDR(args), "only two args expected");

    /* Evaluate expression for return value. */
    args = lisplist_copy (args);
    lispgc_push (args);

    tmp = CDR(args);
    RPLACA(tmp, lispeval (CAR(tmp)));
    ret = CONS(lisp_atom_evaluated_return_from, args);

    lispgc_pop ();
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
lispptr
lispspecial_tagbody (lispptr body)
{
    lispptr res = lispptr_nil;
    lispptr tag;
    lispptr p;
    lispptr car;

    p = body;
    while (1) {
tag_found:
	/* Return on end of list. */
	if (p == lispptr_nil)
	    break;

        /* Evaluate expression, skip non-expression. */
	car = CAR(p);
	if (LISPPTR_IS_EXPR(car) == FALSE)
            goto next;

        res = lispeval (car);

        /* Pass through RETURN-FROM for BLOCK. */
        if (lispeval_is_return (res))
            return res;

        /* Continue to next if expression didn't return a GO expression. */
	if (!lispeval_is_go (res))
            goto next;

	/* We have a GO. Continue after occurence of the tag. */
        tag = CDR(res);
	DOLIST(p, body) {
	    if (CAR(p) != tag)
		continue;

	    p = CDR(p);
	    LISPLIST_FREE_EARLY(res);
	    goto tag_found;
	}

	return res;

next:
        p = CDR(p);
    }

    return lispptr_nil;
}

/*
 * (GO tag)
 *
 * Inside a TAGBODY, continue evaluation at tag.
 */
lispptr
lispspecial_go (lispptr args)
{
    return CONS(lisp_atom_evaluated_go, lisparg_get (args));
}

/*
 * (FUNCTION var | lambda-expression)
 *
 * Return function atom referred to by a variable's function pointer or
 * create one from a LAMBDA expression.
 */
lispptr
lispspecial_function (lispptr fun)
{
    lispptr car;
    lispptr f;
    lispptr args_body;

    if (fun == lispptr_nil)
	return lisperror (fun, "function name expected");
    if (CDR(fun) != lispptr_nil)
	return lisperror (fun, "single argument expected");

    car = CAR(fun);

    switch (LISPPTR_TYPE(car)) {
        case ATOM_EXPR:
	    break;

        case ATOM_VARIABLE:
            return LISPATOM_FUN(car);

        case ATOM_FUNCTION:
        case ATOM_BUILTIN:
        case ATOM_SPECIAL:
	    return car;

        default:
	    goto no_fun;
    }

    if (LISPPTR_IS_ATOM(CAR(car)) && CAR(car) != lispatom_lambda)
        goto no_fun;

    args_body = LISPPTR_IS_EXPR(CAR(car)) ?  car : CDR(car);
    if (args_body == lispptr_nil)
        return lisperror (fun, "argument list and body missing");

    args_body = lisplist_copy (args_body);
    lispgc_push (args_body);

    lisparg_apply_keyword_package (CAR(args_body));
    f = lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_FUNCTION, args_body);
    lispgc_retval (f);
    lispenv_create (f);

    lispgc_pop ();
    return f;

no_fun:
    return lisperror (car, "function or argument/body pair expected");
}

char *lisp_special_names[] = {
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

lispevalfunc_t lispeval_xlat_spec[] = {
    lispspecial_setq,
    lispspecial_macro,
    lispspecial_special,
    lispspecial_cond,
    lispspecial_quote,
    lispspecial_progn,
    lispspecial_block,
    lispspecial_return_from,
    lispspecial_tagbody,
    lispspecial_go,
    lispspecial_function,
    lispatom_builtin_set_atom_fun,
    lispdebug_builtin_set_breakpoint,
    lispdebug_builtin_remove_breakpoint,
    NULL
};

/*
 * Call built-in special operator
 */
lispptr
lispspecial (lispptr func, lispptr expr)
{
    return lispeval_xlat_function (lispeval_xlat_spec, func, expr, FALSE);
}

void
lispspecial_init ()
{
    lisp_atom_evaluated_go
        = lispatom_get ("%%EVALD-GO", LISPCONTEXT_PACKAGE());
    lisp_atom_evaluated_return_from
        = lispatom_get ("%%EVALD-RETURN-FROM", LISPCONTEXT_PACKAGE());
    lispatom_lambda
        = lispatom_get ("LAMBDA", LISPCONTEXT_PACKAGE());

    EXPAND_UNIVERSE(lispatom_lambda);
}
