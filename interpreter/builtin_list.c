/*
 * TRE interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
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

#ifdef TRE_BUILTIN_ASSOC

treptr
trelist_builtin_assoc (treptr args)
{
	treptr key;
	treptr list;
	treptr test;
	treptr res;
	treptr fake;
	treptr car;
	treptr elm;

	key = CAR(args);
	list = CADR(args);
	test = CDDR(args) != treptr_nil ?
			CADDDR(args) :
			treptr_nil;

	while (list != treptr_nil) {
		elm = CAR(list);
		car = CAR(elm);
		if (test == trelist_builtin_eq_symbol && car == key)
			return elm;
		if (test == treptr_nil) {
			if (treatom_eql (car, key) != treptr_nil)
				return elm;
		} else {
    		fake = CONS(test, CONS(key, CONS(car, treptr_nil)));
    		tregc_push (fake);

    		res = treeval (fake);

    		tregc_pop ();
    		TRELIST_FREE_EARLY(fake);
			if (res != treptr_nil)
				return elm;
		}

		list = CDR(list);
	}
	return treptr_nil;
}
#endif /* #ifdef TRE_BUILTIN_ASSOC */

#ifdef TRE_BUILTIN_MEMBER

treptr
trelist_builtin_member (treptr args)
{
	treptr key = CAR(args);
	treptr list = CDR(args);
	treptr sublist;
	treptr test = treptr_nil;
	treptr l;
	treptr fake;
	treptr res;

	l = list;
	while (l != treptr_nil) {
		if (CAR(l) == trelist_builtin_test_symbol) {
			test = CADR(l);
			break;
		}
		l = CDR(l);
	}

	while (list != treptr_nil) {
		sublist = CAR(list);
		if (sublist == trelist_builtin_test_symbol)
			break;
		while (sublist != treptr_nil) {
			if (test == treptr_nil) {
				if (treatom_eql (CAR(sublist), key) != treptr_nil)
					return treptr_t;
			} else {
    			fake = CONS(test, CONS(key, CONS(CAR(sublist), treptr_nil)));
    			tregc_push (fake);

    			res = treeval (fake);

    			tregc_pop ();
    			TRELIST_FREE_EARLY(fake);
				if (res != treptr_nil)
					return treptr_t;
			}

			sublist = CDR(sublist);
		}
		list = CDR(list);
	}
	return treptr_nil;
}

#endif /* #ifdef TRE_BUILTIN_MEMBER */

void
trelist_builtin_init ()
{
	trelist_builtin_eq_symbol = treatom_get ("EQ", treptr_nil);
	trelist_builtin_test_symbol = treatom_get ("TEST", tre_package_keyword);
}
