/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Arguement related section
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
#include "xxx.h"

lispptr lisp_atom_rest;
lispptr lisp_atom_optional;
lispptr lisp_atom_key;

/*
 * Get the first element in argument list.
 *
 * An error will be issued if the list doesn't contain exactly one element.
 */
lispptr
lisparg_get (lispptr list)
{   
    if (LISPPTR_IS_EXPR(list) == FALSE)
        return lisperror (list, "argument expected");
    
    if (CDR(list) != lispptr_nil)
        return lisperror (list, "single argument expected");
    
    return CAR(list);
}

/*
 * Get the first two elements from a list.
 *
 * An error will be issued if the list doesn't contain exactly two elements.
 */
void
lisparg_get2 (lispptr *a, lispptr *b, lispptr list)
{
    lispptr  cdr;
    lispptr  tmp;

    *a = lispptr_nil;
    *b = lispptr_nil;
    while (list == lispptr_nil)
        list = lisperror (list, "two args required");

    *a = CAR(list);

    cdr = CDR(list);
    if (cdr == lispptr_nil) {
        for (tmp = cdr; tmp == lispptr_nil;)
            tmp = lisperror (list, "two args required (just one given). "
                                   "Specify second");
        *b = tmp;
    } else
        *b = CAR(cdr);

    if (CDR(cdr) != lispptr_nil)
        lispwarn (list, "no more than two args required.");
}

#define _ADDF(to, what) \
    { lispptr _tmp = what;  \
      RPLACD(to, _tmp);	  \
      to = _tmp; }

/*
 * Expand argument keywords
 *
 * 'argdef'	Unexpanded list of forms with keywords.
 * 'args'	Unexpanded list of values.
 * 'rvars'	Expanded list of forms. NOT GC SAVE!
 * 'rvals'	Expanded list of values. NOT GC SAVE!
 * 'do_argeval' Evaluate values.
 *
 * This expander supports the &REST, &OPTIONAL and &KEY keywords, including
 * initial values and sublevel arguments.
 */
void
lisparg_expand (lispptr *rvars, lispptr *rvals, lispptr iargdef, lispptr args,
                bool do_argeval)
{
    lispptr   argdef = iargdef;
    lispptr   svars;
    lispptr   svals;
    lispptr   var;
    lispptr   val;
    lispptr   dvars;
    lispptr   dvals;
    lispptr   vars;
    lispptr   vals;
    lispptr   form;
    lispptr   init;
    lispptr   key;
    unsigned  kpos;

    dvars = vars = CONS(lispptr_nil, lispptr_nil);
    lispgc_push (dvars);
    dvals = vals = CONS(lispptr_nil, lispptr_nil);
    lispgc_push (dvals);

    /* Process an unlimited number of arguments. */
    while (1) {
	/* Stop, if all arguments are processed. */
        if (argdef == lispptr_nil)
	    break;

        if (LISPPTR_IS_EXPR(argdef) == FALSE) {
	    lisperror_norecover (iargdef, "argument definition must be a list");
	    return;
	}

	/* Fetch next form and argument. */
        var = CAR(argdef);
	val = (args != lispptr_nil) ?
	      CAR(args) :
	      lispptr_nil;

	/* Process sub-level argument list. */
        if (LISPPTR_IS_EXPR(var)) {
            if (LISPPTR_IS_EXPR(val) == FALSE) {
	        lisperror_norecover (var, "list type argument expected");
                goto error;
            }

	    lisparg_expand (&svars, &svals, var, val, do_argeval);
            RPLACD(dvars, svars);
            RPLACD(dvals, svals);
	    dvars = lisplist_last (dvars);
	    dvals = lisplist_last (dvals);
	    goto next;
        }

        /* Process &REST argument. */
	if (var == lisp_atom_rest) {
	    /* Get form after keyword. */
	    _ADDF(dvars, lisplist_copy (CDR(argdef)));

	    /* Evaluate following arguments if so desired. */
	    svals = (do_argeval) ? lispeval_args (args) : args;

	    /* Add arguments as a list. */
	    _ADDF(dvals, CONS(svals, lispptr_nil));
	    args = lispptr_nil;
	    break;
        }

        /* Process &OPTIONAL argument. */
	if (var == lisp_atom_optional) {
            argdef = CDR(argdef);
	    while (1) {
                if (argdef == lispptr_nil) {
		    if (args != lispptr_nil)
			lisperror (args, "too many &OPTIONAL arguments - "
					 "(continue to ignore)");
		    break;
		}

	        /* Get form. */
		form = CAR(argdef);

		/* Get init value. */
		init = lispptr_nil;
		if (LISPPTR_IS_EXPR(form)) {
		    init = CADR(form);
		    form = CAR(form);
		}

	        _ADDF(dvars, CONS(form, lispptr_nil));

		svals = (args != lispptr_nil) ? CAR(args) : init;

	        if (do_argeval)
		    svals = lispeval (svals);

	        /* Add argument as a list. */
	        _ADDF(dvals, CONS(svals, lispptr_nil));

	        argdef = CDR(argdef);
		if (args != lispptr_nil)
	            args = CDR(args);
	    }
	    args = lispptr_nil;
	    break;
        }

        /* Process &KEY argument. */
	if (var == lisp_atom_key) {
            argdef = CDR(argdef);
	    while (argdef != lispptr_nil) {
	        key = CAR(argdef);
		init = lispptr_nil;
                if (LISPPTR_IS_EXPR(key)) {
		    init = CADR(key);
		    key = CAR(key);
 		}

                /* Get position of key in argument list. */
		kpos = (unsigned) lisplist_position (key, args);
	 	if (kpos != (unsigned) -1) {
		    /* Get argument after key. */
		    svals = lisplist_nth (args, kpos + 1);

		    /* Remove keyword and value from argument list. */
        	    if (CDR(args) == lispptr_nil)
	    	        args = lisperror (
                            args, "missing argument after keyword"
                        );
		    args = lisplist_delete (kpos, args);
		    args = lisplist_delete (kpos, args);
		} else
		    svals = init;

		/* Evaluate value. */
  		if (do_argeval)
		    svals = lispeval (svals);

		lispgc_push (svals);
		key = lispatom_get (LISPATOM_NAME(key), lispptr_nil);
		_ADDF(dvars, CONS(key, lispptr_nil));
		_ADDF(dvals, CONS(svals, lispptr_nil));
		lispgc_pop ();

	        argdef = CDR(argdef);
	    }
	    break;
        }

        if (args == lispptr_nil)
	    val = lisperror (argdef, "missing argument");

	/* Evaluate single argument if so desired. */
        if (do_argeval)
	    val = lispeval (CAR(args));

        lispgc_push (val);
        _ADDF(dvars, CONS(var, lispptr_nil));
        _ADDF(dvals, CONS(val, lispptr_nil));
        lispgc_pop ();

next:
	argdef = CDR(argdef);
	args = CDR(args);
    }

    if (args != lispptr_nil)
	lisperror (args, "too many arguments (continue to ignore)");

    *rvars = CDR(vars);
    *rvals = CDR(vals);

error:
    LISPLIST_FREE_EARLY(vars);
    LISPLIST_FREE_EARLY(vals);

    lispgc_pop ();
    lispgc_pop ();
}

lispptr
lisparg_get_keyword (lispptr a)
{
    return lispatom_get (LISPATOM_NAME(a), lisp_package_keyword);
}

void
lisparg_apply_keyword_package (lispptr args)
{
    lispptr  a;

    if (args == lispptr_nil)
	return;

    if (LISPPTR_IS_EXPR(CAR(args)))
	lisparg_apply_keyword_package (CAR(args));
    else {
	if (CAR(args) == lisp_atom_key) {
	    DOLIST(a, CDR(args)) {
		if (LISPPTR_IS_EXPR(CAR(a)))
		    RPLACA(CAR(a), lisparg_get_keyword (CAAR(a)));
	        else
		    RPLACA(a, lisparg_get_keyword (CAR(a)));
	    }
	    return;
	}
    }

    lisparg_apply_keyword_package (CDR(args));
}

void
lisparg_init (void)
{
    /* Create keywords. */
    lisp_atom_rest = lispatom_get ("&REST", lispptr_nil);
    lisp_atom_optional = lispatom_get ("&OPTIONAL", lispptr_nil);
    lisp_atom_key = lispatom_get ("&KEY", lispptr_nil);
    EXPAND_UNIVERSE(lisp_atom_rest);
    EXPAND_UNIVERSE(lisp_atom_optional);
    EXPAND_UNIVERSE(lisp_atom_key);

    lispthread_make ();
}
