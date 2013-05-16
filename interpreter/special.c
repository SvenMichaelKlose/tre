/*
 * tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdio.h>

#include "config.h"
#include "ptr.h"
#include "alloc.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "builtin.h"
#include "special.h"
#include "error.h"
#include "gc.h"
#include "debug.h"
#include "thread.h"
#include "argument.h"
#include "xxx.h"
#include "eval.h"
#include "bytecode.h"
#include "array.h"
#include "io.h"
#include "main.h"
#include "print.h"
#include "symbol.h"

#include "builtin_debug.h"
#include "builtin_atom.h"

#ifdef INTERPRETER

treptr tre_atom_evaluated_go;
treptr tre_atom_evaluated_return_from;

bool
treeval_is_return (treptr x)
{
	return !(TREPTR_IS_ATOM(x)
    		 || CAR(x) != tre_atom_evaluated_return_from
			 || TREPTR_IS_ATOM(CDR(x))
			 || TREPTR_IS_ATOM(CDDR(x))
			 || CDDDR(x) != treptr_nil);
}

bool
treeval_is_go (treptr x)
{
	return !(TREPTR_IS_ATOM(x)
    		 || CAR(x) != tre_atom_evaluated_go
			 || TREPTR_IS_CONS(CDR(x)));
}

bool
treeval_is_jump (treptr p)
{
    return treeval_is_return (p) || treeval_is_go (p);
}

treptr
trespecial_setq (treptr list)
{
    treptr  car;
    treptr  cdr;
    treptr  tmp;
	long     argnum = 1;

    while (list == treptr_nil)
		list = treerror (treptr_invalid, "arguments expected");

    do {
		car = trearg_typed (argnum, TRETYPE_SYMBOL, CAR(list), "SETQ place");

		argnum++;
        list = CDR(list);
        if (list == treptr_nil) {
	    	cdr = treerror (list, "even number arguments expected - supply the missing one");
			list = treptr_nil;
		} else {
        	tmp = CDR(list);
        	cdr = treeval (CAR(list));
        	list = tmp;
		}

		TREEVAL_RETURN_JUMP(cdr);

        treatom_set_value (car, cdr);

		argnum++;
    } while (list != treptr_nil);

    return cdr;
}

treptr
trespecial_macro (treptr list)
{
    treptr  f;
    treptr  expr = trelist_copy (list);

    f = treatom_alloc (TRETYPE_MACRO);
    TRESYMBOL_VALUE(TREPTR_INDEX(f)) = expr;

    return f;
}

treptr
trespecial_special (treptr list)
{
    treptr  expr = trelist_copy (list);
    treptr  ret;

    tregc_push (expr);
    ret = treatom_alloc (TRETYPE_USERSPECIAL);
    TRESYMBOL_VALUE(TREPTR_INDEX(ret)) = expr;
    tregc_pop ();

    return ret;
}

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

treptr
trespecial_quote (treptr list)
{
    if (list == treptr_nil)
        treerror (treptr_nil, "argument expected");
    return CAR(list);
}

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

treptr
trespecial_return_from (treptr args)
{
    treptr tmp;
    treptr evl;
    treptr ret;

    if (args == treptr_nil)
		return treerror (treptr_invalid, "tag and expression expected");
    if (CDR(args) == treptr_nil)
		return treerror (treptr_invalid, "expression missing after tag");
    if (CDDR(args) != treptr_nil)
		return treerror (CDDR(args), "only two args expected");

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
		if (p == treptr_nil)
	    	break;

		car = CAR(p);
		if (TREPTR_IS_ATOM(car))
            goto next;

        res = treeval (car);

        if (treeval_is_return (res))
            return res;

		if (treeval_is_go (res)) {
            tag = CDR(res);
		    DOLIST(p, body) {
	    	    if (CAR(p) != tag)
				    continue;

	    	    p = CDR(p);
	    	    TRELIST_FREE_EARLY(res);
	    	    goto tag_found;
		    }
		    return res;
        }
next:
        p = CDR(p);
    }

    return treptr_nil;
}

treptr
trespecial_go (treptr args)
{
    return CONS(tre_atom_evaluated_go, trearg_get (args));
}

treptr
trespecial_past_lambda (treptr x)
{
	return (TREPTR_IS_ATOM(FIRST(x)) && FIRST(x) == treatom_lambda)
			? CDR(x)
			: x;
}

treptr
trespecial_function_from_expr (treptr expr)
{
    treptr f;
    treptr x = trespecial_past_lambda (expr);

    if (x == treptr_nil)
        return treerror (expr, "argument list and body missing");
    if (TREPTR_IS_ATOM(CAR(x)) && CAR(x) != treptr_nil)
        return treerror (expr, "argument list expected instead of atom");

    f = treatom_alloc (TRETYPE_FUNCTION);
    TRESYMBOL_VALUE(TREPTR_INDEX(f)) = x;

    return f;
}

treptr
trespecial_function (treptr args)
{
    treptr arg;

    if (args == treptr_nil)
		return treerror (args, "function name expected");
    if (CDR(args) != treptr_nil)
		return treerror (args, "single argument expected");

    arg = FIRST(args);

    switch (TREPTR_TYPE(arg)) {
        case TRETYPE_CONS:
			return trespecial_function_from_expr (arg);

        case TRETYPE_SYMBOL:
            return TRESYMBOL_FUN(arg);

        case TRETYPE_FUNCTION:
        case TRETYPE_BUILTIN:
        case TRETYPE_SPECIAL:
			return arg;

		default:
			return treerror (arg, "FUNCTION expects a symbol, function, special form or function expression");
    }

    return treerror (arg, "function or argument/body pair expected");
}

#endif /* #ifdef INTERPRETER */

char *tre_special_names[] = {
    "SETQ", "%SET-ATOM-FUN",
    "MACRO", "SPECIAL",
#ifdef INTERPRETER
    "COND", "?",
    "QUOTE", "%QUOTE",
    "PROGN",
    "BLOCK", "RETURN-FROM", "TAGBODY", "GO",
    "FUNCTION",
#endif /* #ifdef INTERPRETER */
    "SET-BREAKPOINT", "REMOVE-BREAKPOINT",
    NULL
};

treevalfunc_t treeval_xlat_special[] = {
    trespecial_setq,
    treatom_builtin_set_atom_fun,
    trespecial_macro,
    trespecial_special,
#ifdef INTERPRETER
    trespecial_cond,
    trespecial_if,
    trespecial_quote,
    trespecial_quote,
    trespecial_progn,
    trespecial_block,
    trespecial_return_from,
    trespecial_tagbody,
    trespecial_go,
    trespecial_function,
    tredebug_builtin_set_breakpoint,
    tredebug_builtin_remove_breakpoint,
#endif /* #ifdef INTERPRETER */
    NULL
};

treptr
trespecial (treptr func, treptr args)
{
    return treeval_xlat_function (treeval_xlat_special, func, args, FALSE);
}

void
trespecial_init ()
{
#ifdef INTERPRETER
    tre_atom_evaluated_go = treatom_get ("%%EVALD-GO", TRECONTEXT_PACKAGE());
	EXPAND_UNIVERSE(tre_atom_evaluated_go);

    tre_atom_evaluated_return_from = treatom_get ("%%EVALD-RETURN-FROM", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(tre_atom_evaluated_return_from);

    treatom_lambda = treatom_get ("LAMBDA", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treatom_lambda);
#endif /* #ifdef INTERPRETER */
}
