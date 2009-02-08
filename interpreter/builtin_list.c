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
