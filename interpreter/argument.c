/*
 * tré – Copyright (c) 2005–2008,2012–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include <stdio.h>

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "eval.h"
#include "builtin.h"
#include "number.h"
#include "error.h"
#include "special.h"
#include "gc.h"
#include "print.h"
#include "debug.h"
#include "thread.h"
#include "xxx.h"
#include "symbol.h"

treptr tre_atom_rest;
treptr tre_atom_body;
treptr tre_atom_optional;
treptr tre_atom_key;

treptr
trearg_get (treptr list)
{
   	if (NOT(list))
       	return treerror (treptr_invalid, "Argument expected.");

   	if (TREPTR_IS_ATOM(list))
       	return treerror (list, "Atom instead of list - need 1 argument.");
    
    if (NOT_NIL(CDR(list)))
        trewarn (list, "Single argument expected.");
    
    return CAR(list);
}

void
trearg_get2 (treptr *a, treptr *b, treptr list)
{
    treptr  second = treptr_nil;

    *a = treptr_nil;
    *b = treptr_nil;

	do {
   		while (NOT(list))
        	list = treerror (treptr_invalid, "Two arguments expected.");

   		if (TREPTR_IS_CONS(list))
			break;

       	list = treerror (list, "Atom instead of list - need two arguments.");
	} while (TRUE);

    if (NOT(CDR(list))) {
    	while (NOT(second))
        	second = treerror (treptr_invalid, "Second argument missing.");
	} else {
		second = CADR(list);

    	if (CDR(list) && NOT_NIL(CDDR(list)))
        	trewarn (list, "no more than two args required - ignoring rest");
	}

    *a = CAR(list);
    *b = second;
}

treptr
trearg_correct (tre_size argnum, unsigned type, treptr x, const char * descr)
{
	char buf[4096];

	if (descr == NULL)
		descr = "";

	snprintf (buf, 4096, "Argument %ld to %s: %s expected instead of %s.",
			  (long) argnum, descr,
			  treerror_typename (type),
			  treerror_typename (TREPTR_TYPE(x)));

	return treerror (x, buf);
}

treptr
trearg_typed (tre_size argnum, unsigned type, treptr x, const char * descr)
{
	if (type == TRETYPE_FUNCTION && (TREPTR_TYPE(x) == TRETYPE_FUNCTION || TREPTR_TYPE(x) == TRETYPE_MACRO))
        return x;

	while ((type == TRETYPE_ATOM && TREPTR_TYPE(x) == TRETYPE_CONS)
		   || (type != TRETYPE_ATOM && TREPTR_TYPE(x) != type))
		x = trearg_correct (argnum, type, x, descr);

	return x;
}

#define _ADDF(to, what) \
    { treptr _tmp = what;  \
      RPLACD(to, _tmp);	  \
      to = _tmp; }

void
trearg_expand (treptr * rvars, treptr * rvals, treptr iargdef, treptr args, bool do_argeval)
{
    treptr argdef = iargdef;
    treptr svars;
    treptr svals;
    treptr var;
    treptr val;
    treptr dvars;
    treptr dvals;
    treptr vars;
    treptr vals;
    treptr form;
    treptr init;
    treptr key;
    treptr original_argdef = argdef;
    treptr original_args = args;
    tre_size kpos;

    dvars = vars = CONS(treptr_nil, treptr_nil);
    tregc_push (dvars);
    dvals = vals = CONS(treptr_nil, treptr_nil);
    tregc_push (dvals);
    args = trelist_copy (args);
    tregc_push (args);

    while (1) {
        if (NOT(argdef))
	    	break;

        while (TREPTR_IS_ATOM(argdef)) {
            treprint (original_argdef);
            treprint (original_args);
	    	argdef = treerror (iargdef, "Argument definition must be a list.");
        }

		/* Fetch next form and argument. */
        var = CAR(argdef);
		val = (NOT_NIL(args)) ? CAR(args) : treptr_nil;

		/* Process sub-level argument list. */
        if (TREPTR_IS_CONS(var)) {
            while (TREPTR_IS_ATOM(val)) {
                treprint (original_argdef);
                treprint (original_args);
	        	val = treerror (val, "List type argument expected.");
            }

	    	trearg_expand (&svars, &svals, var, val, do_argeval);
            RPLACD(dvars, svars);
            RPLACD(dvals, svals);
	    	dvars = trelist_last (dvars);
	    	dvals = trelist_last (dvals);
	    	goto next;
        }

        /* Process &REST argument. */
		if (var == tre_atom_rest || var == tre_atom_body) {
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
                if (NOT(argdef)) {
		    		if (NOT_NIL(args)) {
                        treprint (original_argdef);
                        treprint (original_args);
						trewarn (args, "stale &OPTIONAL keyword in argument definition");
                    }
		    		break;
				}

	        	/* Get form. */
				form = CAR(argdef);

				/* Get init value. */
				init = treptr_nil;
				if (TREPTR_IS_CONS(form)) {
		    		init = CADR(form);
		    		form = CAR(form);
				}

	        	_ADDF(dvars, CONS(form, treptr_nil));

				svals = NOT_NIL(args) ?
                            (do_argeval ? treeval (CAR(args)) : CAR(args)) :
                            treeval (init);

	        	/* Add argument as a list. */
	        	_ADDF(dvals, CONS(svals, treptr_nil));

	        	argdef = CDR(argdef);
				if (NOT_NIL(args))
	            	args = CDR(args);
	    	}
	    	args = treptr_nil;
	    	break;
        }

        /* Process &KEY argument. */
		if (var == tre_atom_key) {
            argdef = CDR(argdef);
            if (NOT(argdef) && NOT_NIL(args)) {
                treprint (original_argdef);
                treprint (original_args);
				trewarn (args, "stale &KEY keyword in argument definition");
			}
	    	while (NOT_NIL(argdef)) {
	        	key = CAR(argdef);
				init = treptr_nil;
                if (TREPTR_IS_CONS(key)) {
		    		init = CADR(key);
		    		key = CAR(key);
 				}

                /* Get position of key in argument list. */
				kpos = (tre_size) trelist_position_name (key, args);
	 			if (kpos != (tre_size) -1) {
		    		/* Get argument after key. */
		    		svals = trelist_nth (args, kpos + 1);

		    		/* Remove keyword and value from argument list. */
        	    	while (NOT(CDR(args))) {
                        treprint (original_argdef);
                        treprint (original_args);
	    	        	RPLACD(args, CONS(treerror (args, "Missing argument after keyword."), treptr_nil));
                    }
		    		args = trelist_delete (kpos, args);
		    		args = trelist_delete (kpos, args);

					/* Evaluate value. */
  					if (do_argeval)
		    			svals = treeval (svals);
				} else
		    		svals = treeval (init);

				tregc_push (svals);
				_ADDF(dvars, CONS(key, treptr_nil));
				_ADDF(dvals, CONS(svals, treptr_nil));
				tregc_pop ();

	        	argdef = CDR(argdef);
	    	}
	    	break;
        }

        if (NOT(args)) {
            treprint (original_argdef);
            treprint (original_args);
	    	val = treerror (argdef, "Missing argument.");
        }

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

    if (NOT_NIL(args)) {
        treprint (original_argdef);
        treprint (original_args);
		trewarn (args, "too many arguments (continue to ignore)");
    }

    *rvars = CDR(vars);
    *rvals = CDR(vals);

    tregc_pop ();
    tregc_pop ();
    tregc_pop ();
}

treptr
trearg_get_keyword (treptr a)
{
    return treatom_get (TRESYMBOL_NAME(a), tre_package_keyword);
}

void
trearg_init (void)
{
    tre_atom_rest = treatom_get ("&REST", treptr_nil);
    tre_atom_body = treatom_get ("&BODY", treptr_nil);
    tre_atom_optional = treatom_get ("&OPTIONAL", treptr_nil);
    tre_atom_key = treatom_get ("&KEY", treptr_nil);
    EXPAND_UNIVERSE(tre_atom_rest);
    EXPAND_UNIVERSE(tre_atom_body);
    EXPAND_UNIVERSE(tre_atom_optional);
    EXPAND_UNIVERSE(tre_atom_key);

    trethread_make ();
}

#endif /* #ifdef INTERPRETER */
