/*
 * TRE interpreter
 * Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>
 *
 * Built-in list functions.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "number.h"
#include "argument.h"
#include "builtin.h"
#include "builtin_list.h"
#include "xxx.h"
#include "special.h"

#include "gc.h"
#include "thread.h"
#include "builtin_atom.h"

treptr trelist_builtin_eq_symbol;
treptr trelist_builtin_test_symbol;

/*tredoc
  (cmd :name CONS
	(arg :name a)
	(arg :name d)
	(Returns "A new cell containing the first argument as the CAR "
		   *and the second argument as the CDR.")
	(see-also CAR CDR))
 */
treptr
trelist_builtin_cons (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return CONS(car, cdr);
}

/*tredoc
  (cmd :name LIST
	(arg :name expression :occurrence *)
	(Returns "Copy of argument list."))
 */
treptr
trelist_builtin_list (treptr list)
{
    return trelist_copy (list);
}

treptr
trelist_builtin_cxr_arg (treptr list)
{
    treptr arg = trearg_get (list);

    RETURN_NIL(arg);
	return trearg_typed (1, TRETYPE_CONS, arg, NULL);
}

/*tredoc
  (cmd :name CAR
	(arg :type cons)
	(returns "CAR of cell. Returns NIL if the argument is NIL.))
 */
treptr
trelist_builtin_car (treptr list)
{
    treptr arg = trelist_builtin_cxr_arg (list);

    RETURN_NIL(arg);
    return CAR(arg);
}

/*tredoc
  (cmd :name CDR
	(arg :type cons)
	(returns "CAR of cell. Returns NIL if the argument is NIL.))
 */
treptr
trelist_builtin_cdr (treptr list)
{
    treptr arg = trelist_builtin_cxr_arg (list);
    RETURN_NIL(arg);
    return CDR(arg);
}

#define TRELISTARG_GET2(cons, new, list) \
    treptr  cons;	\
    treptr  new;	\
    trearg_get2 (&cons, &new, list);	\
	cons = trearg_typed (1, TRETYPE_CONS, cons, NULL);

/*tredoc
  (cmd :name RPLACA
	(arg :type cons)
	(arg :type obj)
	(descr "Set adress register of cell to new value.")
	(returns-argument obj))
 */
treptr
trelist_builtin_rplaca (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACA(cons, new);
    return cons;
}

/*tredoc
  (cmd :name RPLACD
	(arg :type cons)
	(arg :type obj)
	(descr "Set decrement register of cell to new value.")
	(returns-argument obj))
 */
treptr
trelist_builtin_rplacd (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACD(cons, new);
    return cons;
}

/*tredoc
  (cmd :name CONSP
	(arg :type obj :occurrence *)
	(descr "Checks if all objects are conses.")
	(returns boolean))
 */
treptr
trelist_builtin_consp (treptr list)
{
	treptr x;

	DOLIST(x, list)
        if (TREPTR_IS_ATOM(CAR(x)))
		    return treptr_nil;
    return treptr_t;
}

treptr
treeval_noargs (treptr efunc, treptr fake)
{
    if (TREPTR_IS_FUNCTION(efunc))
        return treeval_funcall (efunc, fake, FALSE);
    else if (TREPTR_IS_BUILTIN(efunc))
        return treeval_xlat_function (treeval_xlat_builtin, efunc, fake, FALSE);
    else if (TREPTR_IS_SPECIAL(efunc))
        return trespecial (efunc, fake);
    else
        return treerror (efunc, "function expected");
}

#ifdef TRE_BUILTIN_ASSOC

treptr
trelist_builtin_assoc (treptr args)
{
	treptr key;
	treptr list;
	treptr test;
	treptr etest;
	treptr res;
	treptr fake;
	treptr elm;
	treptr elmkey;

	key = CAR(args);
	test = treptr_nil;
	if (CDDR(args) != treptr_nil) {
	    if (CADDR(args) != trelist_builtin_test_symbol)
			treerror_norecover (args, "ASSOC: too many args");
		test = CADDDR(args);
	}

	etest = treeval (test);
	tregc_push (etest);
	list = CADR(args);
	while (list != treptr_nil) {
		while (TREPTR_IS_CONS(list) == FALSE)
			list = treerror (list, "ASSOC: cons or NIL expected");
		elm = CAR(list);
		while (TREPTR_IS_CONS(elm) == FALSE)
			elm = treerror (elm, "ASSOC: cons with pair expected");
		elmkey = CAR(elm);
		if (test == trelist_builtin_eq_symbol && elmkey == key)
			goto got_it;
		if (test == treptr_nil) {
			if (treatom_eql (elmkey, key) != treptr_nil)
				goto got_it;
		} else {
    		fake = CONS(etest, CONS(key, CONS(elmkey, treptr_nil)));
    		tregc_push (fake);

			res = treeval_noargs (etest, fake);

    		tregc_pop ();
    		TRELIST_FREE_EARLY(fake);
			if (res != treptr_nil)
				goto got_it;
		}

		list = CDR(list);
	}

	tregc_pop ();
	return treptr_nil;

got_it:
	tregc_pop ();
	return elm;
}
#endif /* #ifdef TRE_BUILTIN_ASSOC */

#ifdef TRE_BUILTIN_MEMBER

treptr
trelist_builtin_member (treptr args)
{
	treptr key = CAR(args);
	treptr list = CDR(args);
	treptr listend;
	treptr sublist;
	treptr test = treptr_nil;
	treptr etest;
	treptr l;
	treptr fake;
	treptr res;

	l = list;
	listend = treptr_nil;
	while (l != treptr_nil) {
		if (CAR(l) == trelist_builtin_test_symbol) {
			test = CADR(l);
			listend = l;
			break;
		}
		l = CDR(l);
	}

	etest = treeval (test);
	tregc_push (etest);
	while (list != treptr_nil && list != listend) {
		sublist = CAR(list);
		if (sublist == trelist_builtin_test_symbol)
			break;
		while (sublist != treptr_nil) {
			if (test == treptr_nil) {
				if (treatom_eql (CAR(sublist), key) != treptr_nil) {
					res = sublist;
					goto got_t;
				}
			} else {
    			fake = CONS(etest, CONS(key, CONS(CAR(sublist), treptr_nil)));
    			tregc_push (fake);

				res = treeval_noargs (etest, fake);

    			tregc_pop ();
    			TRELIST_FREE_EARLY(fake);
				if (res != treptr_nil) {
					res = sublist;
					goto got_t;
				}
			}

			sublist = CDR(sublist);
		}
		list = CDR(list);
	}

	tregc_pop ();
	return treptr_nil;

got_t:
	tregc_pop ();
	return res;
}

#endif /* #ifdef TRE_BUILTIN_MEMBER */

void
trelist_builtin_init ()
{
	trelist_builtin_eq_symbol = treatom_get ("EQ", treptr_nil);
	trelist_builtin_test_symbol = treatom_get ("TEST", tre_package_keyword);
}
