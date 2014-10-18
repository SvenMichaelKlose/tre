/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
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
#include "special_exception.h"
#include "error.h"
#include "gc.h"
#include "debug.h"
#include "thread.h"
#include "argument.h"
#include "xxx.h"
#include "eval.h"
#include "bytecode.h"
#include "array.h"
#include "stream.h"
#include "main.h"
#include "print.h"
#include "symtab.h"
#include "symbol.h"
#include "function.h"

#include "builtin_debug.h"
#include "builtin_atom.h"
#include "builtin_symbol.h"

#ifdef INTERPRETER

treptr tre_atom_evaluated_go;
treptr tre_atom_evaluated_return_from;

treptr
trespecial_setq (treptr list)
{
    treptr  a;
    treptr  d;
    treptr  tmp;
	long    argnum = 1;

#ifndef TRE_NO_ASSERTIONS
    while (NOT(list))
		list = treerror (treptr_invalid, "Arguments expected.");
#endif

    do {
		a = trearg_typed (argnum, TRETYPE_SYMBOL, CAR(list), "SETQ place");

		argnum++;
        list = CDR(list);
#ifndef TRE_NO_ASSERTIONS
        if (NOT(list))
	    	treerror_norecover (treptr_invalid, "Even number arguments expected - please provide the missing one.");
#endif
       	tmp = CDR(list);
       	d = eval (CAR(list));
       	list = tmp;

		TREEVAL_RETURN_JUMP(d);

        tresymbol_set_value (d, a);

		argnum++;
    } while (NOT_NIL(list));

    return d;
}

treptr
trespecial_past_lambda (treptr x)
{
	return (ATOMP(FIRST(x)) && FIRST(x) == treatom_lambda) ? CDR(x) : x;
}

treptr
trespecial_function_from_expr (treptr expr)
{
    treptr x = trespecial_past_lambda (expr);

#ifndef TRE_NO_ASSERTIONS
    if (NOT(x))
        return treerror (expr, "Argument list and body missing.");
    if (ATOMP(CAR(x)) && NOT_NIL(CAR(x)))
        return treerror (expr, "Argument list expected instead of atom.");
#endif

    return trefunction_make (TRETYPE_FUNCTION, x);
}

treptr
trespecial_function (treptr args)
{
    treptr arg;

#ifndef TRE_NO_ASSERTIONS
    if (NOT(args))
		return treerror (args, "Function name expected.");
    if (NOT_NIL(CDR(args)))
		return treerror (args, "Single argument expected.");
#endif

    arg = FIRST(args);

    switch (TREPTR_TYPE(arg)) {
        case TRETYPE_CONS:
			return trespecial_function_from_expr (arg);

        case TRETYPE_SYMBOL:
            return SYMBOL_FUNCTION(arg);

        case TRETYPE_FUNCTION:
        case TRETYPE_BUILTIN:
        case TRETYPE_SPECIAL:
			return arg;

		default:
			return treerror (arg, "FUNCTION expects a symbol, function, special form or function expression.");
    }

    return treerror (arg, "Function or argument/body pair expected.");
}

treptr
trespecial_macro (treptr list)
{
    return trefunction_make (TRETYPE_MACRO, list_copy_tree (list));
}

treptr
trespecial_special (treptr list)
{
    return trefunction_make (TRETYPE_USERSPECIAL, list_copy_tree (list));
}

bool
eval_is_return (treptr x)
{
	return !(ATOMP(x)
    		 || CAR(x) != tre_atom_evaluated_return_from
			 || ATOMP(CDR(x))
			 || ATOMP(CDDR(x))
			 || NOT_NIL(CDDDR(x)));
}

bool
eval_is_go (treptr x)
{
	return !(ATOMP(x)
    		 || CAR(x) != tre_atom_evaluated_go
			 || CONSP(CDR(x)));
}

bool
eval_is_jump (treptr p)
{
    return eval_is_return (p) || eval_is_go (p);
}

treptr
trespecial_if (treptr p)
{
    treptr test;
    treptr body;

#ifndef TRE_NO_ASSERTIONS
    if (ATOMP(p))
        return treerror (p, "Expression expected.");
#endif

    while (NOT_NIL(p)) {
        test = CAR(p);
        p = CDR(p);
        if (NOT(p))
            return eval (test);

        body = CAR(p);
        if (NOT_NIL(eval (test)))
            return eval (body);

        p = CDR(p);
    }

    return treptr_nil;
}

treptr
trespecial_quote (treptr list)
{
#ifndef TRE_NO_ASSERTIONS
    if (NOT(list))
        treerror (treptr_nil, "Argument expected.");
#endif
    return CAR(list);
}

treptr
trespecial_progn (treptr list)
{
    treptr last;

    for (last = treptr_nil; NOT_NIL(list); list = CDR(list)) {
		last = eval (CAR(list));
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
#ifndef TRE_NO_ASSERTIONS
    if (CONSP(tag))
		return treerror (tag, "Tag expected instead of an expression.");
#endif

    p = CDR(args);
    RETURN_NIL(p);

    while (NOT_NIL(p)) {
		last = eval (CAR(p));

		if (!eval_is_return (last)) {
            p = CDR(p);
	    	continue;
        }

        if (tag != CADR(last))
	    	return last;

        p = CADDR(last);
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

#ifndef TRE_NO_ASSERTIONS
    if (NOT(args))
		return treerror (treptr_invalid, "Tag and expression expected.");
    if (NOT(CDR(args)))
		return treerror (treptr_invalid, "Expression missing after tag.");
    if (NOT_NIL(CDDR(args)))
		return treerror (CDDR(args), "Only two args expected.");
#endif

    args = list_copy (args);
    tregc_push (args);

    tmp = CDR(args);
	evl = eval (CAR(tmp));
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
    treptr a;

    p = body;
    while (1) {
tag_found:
		if (NOT(p))
	    	break;

		a = CAR(p);
		if (ATOMP(a))
            goto next;

        res = eval (a);

        if (eval_is_return (res))
            return res;

		if (eval_is_go (res)) {
            tag = CDR(res);
		    DOLIST(p, body) {
	    	    if (CAR(p) != tag)
				    continue;

	    	    p = CDR(p);
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

#endif /* #ifdef INTERPRETER */

char *tre_special_names[] = {
    "SETQ", "%SET-ATOM-FUN",
    "MACRO", "SPECIAL",
#ifdef INTERPRETER
    "?",
    "QUOTE", "%QUOTE",
    "PROGN",
    "BLOCK", "RETURN-FROM", "TAGBODY", "GO",
    "FUNCTION",
    "CATCH", "THROW",
#endif /* #ifdef INTERPRETER */
    "SET-BREAKPOINT", "REMOVE-BREAKPOINT",
    NULL
};

evalfunc_t eval_xlat_special[] = {
    trespecial_setq,
    tresymbol_builtin_set_atom_fun,
    trespecial_macro,
    trespecial_special,
#ifdef INTERPRETER
    trespecial_if,
    trespecial_quote,
    trespecial_quote,
    trespecial_progn,
    trespecial_block,
    trespecial_return_from,
    trespecial_tagbody,
    trespecial_go,
    trespecial_function,
    trespecial_catch,
    trespecial_throw,
    tredebug_builtin_set_breakpoint,
    tredebug_builtin_remove_breakpoint,
#endif /* #ifdef INTERPRETER */
    NULL
};

treptr
trespecial (treptr func, treptr args)
{
    return eval_xlat_function (eval_xlat_special, func, args, FALSE);
}

void
trespecial_init ()
{
#ifdef INTERPRETER
    treptr name;
    treptr fun;
    size_t i;

    for (i = 0; tre_special_names[i] != NULL; i++) {
        fun = treatom_alloc (TRETYPE_SPECIAL);
        ATOM(fun) = (void*) i;
        name = symbol_alloc (tre_special_names[i], treptr_nil);
        tresymbol_set_function (fun, name);
        EXPAND_UNIVERSE(name);
    }

    tre_atom_evaluated_go = symbol_get ("%%EVALD-GO");
	EXPAND_UNIVERSE(tre_atom_evaluated_go);

    tre_atom_evaluated_return_from = symbol_get ("%%EVALD-RETURN-FROM");
    EXPAND_UNIVERSE(tre_atom_evaluated_return_from);

    treatom_lambda = symbol_get ("LAMBDA");
    EXPAND_UNIVERSE(treatom_lambda);
#endif /* #ifdef INTERPRETER */
}
