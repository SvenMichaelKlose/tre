/*
 * TRE interpreter
 * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 *
 * Built-in special forms.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "builtin.h"
#include "special.h"
#include "error.h"
#include "gc.h"
#include "debug.h"
#include "thread.h"
#include "env.h"
#include "argument.h"
#include "xxx.h"
#include "eval.h"

#include "builtin_debug.h"
#include "builtin_atom.h"

treptr tre_atom_evaluated_go;
treptr tre_atom_evaluated_return_from;

/*
 * Convert APPLY arguments into simple list
 *
 * The last element of the list must be a list which is copied and
 * appended to the second last element. The last list is copied because
 * it'd be removed as a part of the temporary argument list.
 */
treptr
trespecial_apply_args (treptr list)
{
    treptr i;
    treptr last;

    RETURN_NIL(list); /* No arguments. */

    /* Handle single argument. */
    if (CDR(list) == treptr_nil) {
        list = treeval (CAR(list));
        if (TREPTR_IS_ATOM(list) && list != treptr_nil)
            goto error;
		return list;
    }

    /* Handle two or more arguments. */
    DOLIST(i, list) {
        if (CDDR(i) != treptr_nil) {
			RPLACA(i, treeval (CAR(i)));
            continue;
		}
        if (CADR(i) == treptr_nil)
	    	break;

		RPLACA(i, treeval (CAR(i)));
        last = treeval (CADR(i));
        if (TREPTR_IS_ATOM(last) && last != treptr_nil)
            goto error;

        RPLACD(i, last);
        break;
    }

    return list;

error:
    return treerror (list, "last argument must be a list "
                           "(waiting for new argument list)");
}

/*tredoc
  (cmd :name APPLY
	(arg :type function)
	(args :type any)
	(descr "Call function with argument list.")
	(returns "Whatever the called function returns."))
 */
treptr
trespecial_apply (treptr list)
{
    treptr  func;
    treptr  args;
    treptr  fake;
    treptr  efunc;
    treptr  res;

    if (list == treptr_nil)
		return treerror (list, "arguments expected");

    func = CAR(list);
    args = trespecial_apply_args (trelist_copy (CDR(list)));

    fake = CONS(func, args);
    tregc_push (fake);

    efunc = treeval (func);
    RPLACA(fake, efunc);

    if (TREPTR_IS_FUNCTION(efunc))
        res = treeval_funcall (efunc, fake, FALSE);
    else if (TREPTR_IS_BUILTIN(efunc))
        res = treeval_xlat_function (treeval_xlat_builtin, efunc, fake, FALSE);
    else if (TREPTR_IS_SPECIAL(efunc))
        res = trespecial (efunc, fake);
    else
        res = treerror (func, "function expected");

    tregc_pop ();
    TRELIST_FREE_EARLY(fake);

    return res;
}

/* Test if expression is an evaluated RETURN-FROM. */
bool
treeval_is_return (treptr x)
{
	return !(TREPTR_IS_ATOM(x)
    		 || CAR(x) != tre_atom_evaluated_return_from
			 || TREPTR_IS_ATOM(CDR(x))
			 || TREPTR_IS_ATOM(CDDR(x))
			 || CDDDR(x) != treptr_nil);
}

/* Test if expression is an evaluated GO. */
bool
treeval_is_go (treptr x)
{
	return !(TREPTR_IS_ATOM(x)
    		 || CAR(x) != tre_atom_evaluated_go
			 || TREPTR_IS_CONS(CDR(x)));
}

/* Test if expression is an evaluated GO or RETURN-FROM. */
bool
treeval_is_jump (treptr p)
{
    return treeval_is_return (p) || treeval_is_go (p);
}

/*tredoc
  (cmd :name SETQ
	(args :occurrence *
	  (arg :type symbol)
	  (arg :name value))
	(descr "Assign quoted value to variable.")
	(returns "The last value assigned."))
 */
treptr
trespecial_setq (treptr list)
{
    treptr  car;
    treptr  cdr;
    treptr  tmp;
	long     argnum = 1;

    /* Check if there're any arguments. */
    while (list == treptr_nil)
		list = treerror (treptr_invalid, "arguments expected");

    do {
        /* Check arguments. */
		car = trearg_typed (argnum, TRETYPE_VARIABLE, CAR(list), "place");

		argnum++;
        list = CDR(list);
        if (list == treptr_nil) {
	    	cdr = treerror (list, "even number arguments expected - supply the missing one");
			list = treptr_nil;
		} else {
			/* Evaluate value expression. */
        	tmp = CDR(list);
        	cdr = treeval (CAR(list));
        	list = tmp;
		}

		/* Catch RETURN-FROM. */
		TREEVAL_RETURN_JUMP(cdr);

        treatom_set_value (car, cdr);

		argnum++;
    } while (list != treptr_nil);

    return cdr;
}

/*tredoc
  (cmd :name MACRO
	(arg :type argument-definition)
	(arg :type expression-list)
	(descr "Create a macro.")
	(returns macro))
 */
treptr
trespecial_macro (treptr list)
{
    treptr  f;
    treptr  expr = trelist_copy (list);

    f = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), TRETYPE_MACRO, expr);
	tregc_push (f);
    treenv_create (f);
	tregc_pop ();

    return f;
}

/*tredoc
  (cmd :name SPECIAL
	(arg :type argument-definition)
	(arg :type expression-list)
	(descr "Create a special function whose arguments are not evaluated.")
	(returns special))
 */
treptr
trespecial_special (treptr list)
{
    treptr  expr = trelist_copy (list);
    treptr  ret;

    /* Create macro atom. */
    tregc_push (expr);
    ret = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), TRETYPE_USERSPECIAL, expr);
    tregc_pop ();

    return ret;
}

/*XXX deprecated
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

    if (TREPTR_IS_ATOM(p))
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

treptr
trespecial_if (treptr p)
{
    treptr test;
    treptr body;

    if (TREPTR_IS_ATOM(p))
        return treerror (p, "expression expected");

    while (p != treptr_nil) {
        test = CAR(p);
        p = CDR(p);
        if (p == treptr_nil)
            return treeval (test);

        body = CAR(p);
        if (treeval (test) != treptr_nil)
            return treeval (body);

        p = CDR(p);
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
    if (TREPTR_IS_CONS(tag))
		return treerror (tag, "tag expected instead of an expression");

    p = CDR(args);
    RETURN_NIL(p);

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
    treptr evl;
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
	evl = treeval (CAR(tmp));
	tregc_push (evl);
    RPLACA(tmp, evl);
    ret = CONS(tre_atom_evaluated_return_from, args);

    tregc_pop ();
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
		if (TREPTR_IS_ATOM(car))
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
 */
treptr
trespecial_function_from_expr (treptr expr)
{
    treptr past_lambda;
    treptr f;

	/* Jump past optional LAMBDA keyword. */
	past_lambda = (TREPTR_IS_ATOM(CAR(expr)) && CAR(expr) == treatom_lambda)
					  ? CDR(expr)
					  : expr;

    if (past_lambda == treptr_nil)
        return treerror (expr, "argument list and body missing");
    if (TREPTR_IS_ATOM(CAR(past_lambda)) && CAR(past_lambda) != treptr_nil)
        return treerror (expr, "argument list expected instead of atom");

    past_lambda = trelist_copy (past_lambda);
    tregc_push (past_lambda);
    f = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), TRETYPE_FUNCTION, past_lambda);
    tregc_push (f);
    treenv_create (f);
    tregc_pop ();

    tregc_pop ();
    return f;
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

    if (fun == treptr_nil)
		return treerror (fun, "function name expected");
    if (CDR(fun) != treptr_nil)
		return treerror (fun, "single argument expected");

    car = CAR(fun);

    switch (TREPTR_TYPE(car)) {
        case TRETYPE_CONS:
			return trespecial_function_from_expr (car);

        case TRETYPE_VARIABLE:
            return TREATOM_FUN(car);

        case TRETYPE_FUNCTION:
        case TRETYPE_BUILTIN:
        case TRETYPE_SPECIAL:
	    	return car;
    }

    return treerror (car, "function or argument/body pair expected");
}

char *tre_special_names[] = {
    "APPLY",
    "SETQ",
    "MACRO", "SPECIAL",
    "COND", "IF",
    "QUOTE",
    "PROGN",
    "BLOCK", "RETURN-FROM", "TAGBODY", "GO",
    "FUNCTION",
    "%SET-ATOM-FUN",
    "SET-BREAKPOINT", "REMOVE-BREAKPOINT",
    NULL
};

treevalfunc_t treeval_xlat_spec[] = {
    trespecial_apply,
    trespecial_setq,
    trespecial_macro,
    trespecial_special,
    trespecial_cond,
    trespecial_if,
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
	EXPAND_UNIVERSE(tre_atom_evaluated_go);

    tre_atom_evaluated_return_from
        = treatom_get ("%%EVALD-RETURN-FROM", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(tre_atom_evaluated_return_from);

    treatom_lambda
        = treatom_get ("LAMBDA", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treatom_lambda);
}
