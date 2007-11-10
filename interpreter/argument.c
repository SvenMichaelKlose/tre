/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Arguement related section
 */

#include "config.h"
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

treptr tre_atom_rest;
treptr tre_atom_optional;
treptr tre_atom_key;

/*
 * Get the first element in argument list.
 *
 * An error will be issued if the list doesn't contain exactly one element.
 */
treptr
trearg_get (treptr list)
{   
    if (TREPTR_IS_EXPR(list) == FALSE)
        return treerror (list, "argument expected");
    
    if (CDR(list) != treptr_nil)
        return treerror (list, "single argument expected");
    
    return CAR(list);
}

/*
 * Get the first two elements from a list.
 *
 * An error will be issued if the list doesn't contain exactly two elements.
 */
void
trearg_get2 (treptr *a, treptr *b, treptr list)
{
    treptr  cdr;
    treptr  tmp;

    *a = treptr_nil;
    *b = treptr_nil;
    while (list == treptr_nil)
        list = treerror (list, "two args required");

    *a = CAR(list);

    cdr = CDR(list);
    if (cdr == treptr_nil) {
        for (tmp = cdr; tmp == treptr_nil;)
            tmp = treerror (list, "two args required (just one given). "
                                   "Specify second");
        *b = tmp;
    } else
        *b = CAR(cdr);

    if (CDR(cdr) != treptr_nil)
        trewarn (list, "no more than two args required.");
}

#define _ADDF(to, what) \
    { treptr _tmp = what;  \
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
trearg_expand (treptr *rvars, treptr *rvals, treptr iargdef, treptr args,
                bool do_argeval)
{
    treptr   argdef = iargdef;
    treptr   svars;
    treptr   svals;
    treptr   var;
    treptr   val;
    treptr   dvars;
    treptr   dvals;
    treptr   vars;
    treptr   vals;
    treptr   form;
    treptr   init;
    treptr   key;
    unsigned  kpos;

    dvars = vars = CONS(treptr_nil, treptr_nil);
    tregc_push (dvars);
    dvals = vals = CONS(treptr_nil, treptr_nil);
    tregc_push (dvals);

    /* Process an unlimited number of arguments. */
    while (1) {
	/* Stop, if all arguments are processed. */
        if (argdef == treptr_nil)
	    	break;

        if (TREPTR_IS_EXPR(argdef) == FALSE) {
	    	treerror_norecover (iargdef, "argument definition must be a list");
	    	return;
		}

		/* Fetch next form and argument. */
        var = CAR(argdef);
		val = (args != treptr_nil) ?
	      CAR(args) :
	      treptr_nil;

		/* Process sub-level argument list. */
        if (TREPTR_IS_EXPR(var)) {
            if (TREPTR_IS_EXPR(val) == FALSE) {
	        	treerror_norecover (var, "list type argument expected");
                goto error;
            }

	    	trearg_expand (&svars, &svals, var, val, do_argeval);
            RPLACD(dvars, svars);
            RPLACD(dvals, svals);
	    	dvars = trelist_last (dvars);
	    	dvals = trelist_last (dvals);
	    	goto next;
        }

        /* Process &REST argument. */
		if (var == tre_atom_rest) {
	    	/* Get form after keyword. */
	    	_ADDF(dvars, trelist_copy (CDR(argdef)));

	    	/* Evaluate following arguments if so desired. */
	    	svals = (do_argeval) ? treeval_args (args) : args;

	    	/* Add arguments as a list. */
	    	_ADDF(dvals, CONS(svals, treptr_nil));
	    	args = treptr_nil;
	    	break;
        }

        /* Process &OPTIONAL argument. */
		if (var == tre_atom_optional) {
            argdef = CDR(argdef);
	    	while (1) {
                if (argdef == treptr_nil) {
		    		if (args != treptr_nil)
						treerror (args, "too many &OPTIONAL arguments - "
					 					"(continue to ignore)");
		    		break;
				}

	        	/* Get form. */
				form = CAR(argdef);

				/* Get init value. */
				init = treptr_nil;
				if (TREPTR_IS_EXPR(form)) {
		    		init = CADR(form);
		    		form = CAR(form);
				}

	        	_ADDF(dvars, CONS(form, treptr_nil));

				svals = (args != treptr_nil) ? CAR(args) : init;

	        	if (do_argeval)
		    		svals = treeval (svals);

	        	/* Add argument as a list. */
	        	_ADDF(dvals, CONS(svals, treptr_nil));

	        	argdef = CDR(argdef);
				if (args != treptr_nil)
	            	args = CDR(args);
	    	}
	    	args = treptr_nil;
	    	break;
        }

        /* Process &KEY argument. */
		if (var == tre_atom_key) {
            argdef = CDR(argdef);
	    	while (argdef != treptr_nil) {
	        	key = CAR(argdef);
				init = treptr_nil;
                if (TREPTR_IS_EXPR(key)) {
		    		init = CADR(key);
		    		key = CAR(key);
 				}

                /* Get position of key in argument list. */
				kpos = (unsigned) trelist_position (key, args);
	 			if (kpos != (unsigned) -1) {
		    		/* Get argument after key. */
		    		svals = trelist_nth (args, kpos + 1);

		    		/* Remove keyword and value from argument list. */
        	    	if (CDR(args) == treptr_nil)
	    	        	args = treerror (
                            args, "missing argument after keyword"
                        );
		    		args = trelist_delete (kpos, args);
		    		args = trelist_delete (kpos, args);
				} else
		    		svals = init;

				/* Evaluate value. */
  				if (do_argeval)
		    		svals = treeval (svals);

				tregc_push (svals);
				key = treatom_get (TREATOM_NAME(key), treptr_nil);
				_ADDF(dvars, CONS(key, treptr_nil));
				_ADDF(dvals, CONS(svals, treptr_nil));
				tregc_pop ();

	        	argdef = CDR(argdef);
	    	}
	    	break;
        }

        if (args == treptr_nil)
	    	val = treerror (argdef, "missing argument");

		/* Evaluate single argument if so desired. */
        if (do_argeval)
	    	val = treeval (CAR(args));

        tregc_push (val);
        _ADDF(dvars, CONS(var, treptr_nil));
        _ADDF(dvals, CONS(val, treptr_nil));
        tregc_pop ();

	next:
		argdef = CDR(argdef);
		args = CDR(args);
    }

    if (args != treptr_nil)
		treerror (args, "too many arguments (continue to ignore)");

    *rvars = CDR(vars);
    *rvals = CDR(vals);

error:
    TRELIST_FREE_EARLY(vars);
    TRELIST_FREE_EARLY(vals);

    tregc_pop ();
    tregc_pop ();
}

treptr
trearg_get_keyword (treptr a)
{
    return treatom_get (TREATOM_NAME(a), tre_package_keyword);
}

void
trearg_apply_keyword_package (treptr args)
{
    treptr  a;

    if (args == treptr_nil)
		return;

    if (TREPTR_IS_EXPR(CAR(args)))
		trearg_apply_keyword_package (CAR(args));
    else {
		if (CAR(args) == tre_atom_key) {
	    	DOLIST(a, CDR(args)) {
				if (TREPTR_IS_EXPR(CAR(a)))
		    		RPLACA(CAR(a), trearg_get_keyword (CAAR(a)));
	        	else
		    		RPLACA(a, trearg_get_keyword (CAR(a)));
	    	}
	    	return;
		}
    }

    trearg_apply_keyword_package (CDR(args));
}

void
trearg_init (void)
{
    /* Create keywords. */
    tre_atom_rest = treatom_get ("&REST", treptr_nil);
    tre_atom_optional = treatom_get ("&OPTIONAL", treptr_nil);
    tre_atom_key = treatom_get ("&KEY", treptr_nil);
    EXPAND_UNIVERSE(tre_atom_rest);
    EXPAND_UNIVERSE(tre_atom_optional);
    EXPAND_UNIVERSE(tre_atom_key);

    trethread_make ();
}
