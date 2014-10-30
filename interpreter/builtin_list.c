/*
 * tré – Copyright (c) 2005–2010,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
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
#include "function.h"
#include "symbol.h"
#include "assert.h"

#include "builtin_atom.h"

treptr list_builtin_eq_symbol;
treptr list_builtin_test_symbol;

treptr
list_builtin_cons (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return CONS(car, cdr);
}

treptr
list_builtin_car (treptr x)
{
    treptr arg = trearg_get (x);
    RETURN_NIL(arg);
    return CAR(arg);
}

treptr
list_builtin_cdr (treptr x)
{
    treptr arg = trearg_get (x);
    RETURN_NIL(arg);
    return CDR(arg);
}

treptr
list_builtin_cpr (treptr x)
{
    treptr arg = trearg_get (x);
    RETURN_NIL(arg);
    return CPR(arg);
}

#define TRELISTARG_GET2(cons, new, list) \
    treptr  cons;	\
    treptr  new;	\
    trearg_get2 (&cons, &new, list);	\
	cons = trearg_typed (1, TRETYPE_CONS, cons, NULL);

treptr
list_builtin_rplaca (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACA(cons, new);
    return cons;
}

treptr
list_builtin_rplacd (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACD(cons, new);
    return cons;
}

treptr
list_builtin_rplacp (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACP(cons, new);
    return cons;
}

treptr
list_consp (treptr x)
{
    if (ATOMP(x))
        return NIL;
    return treptr_t;
}

treptr
list_builtin_consp (treptr list)
{
    return list_consp (trearg_get (list));
}

treptr
list_builtin_last (treptr list)
{
    return last (trearg_get (list));
}

treptr
list_builtin_copy_list (treptr list)
{
    return list_copy (trearg_get (list));
}

treptr
list_builtin_nthcdr (treptr x)
{
    treptr  idx;
    treptr  list;

    trearg_get2 (&idx, &list, x);
    ASSERT_NUMBER(idx);
    ASSERT_LIST(list);

    return nthcdr ((tre_size) TRENUMBER_VAL(idx), list);
}

treptr
list_builtin_nth (treptr x)
{
    treptr  idx;
    treptr  list;

    trearg_get2 (&idx, &list, x);
    ASSERT_NUMBER(idx);
    ASSERT_LIST(list);

    return nth ((tre_size) TRENUMBER_VAL(idx), list);
}

treptr
list_builtin_filter (treptr x)
{
    treptr  predicate;
    treptr  list;

    trearg_get2 (&predicate, &list, x);
    ASSERT_ANY_FUNCTION(predicate);
    ASSERT_LIST(list);

    return filter (predicate, list);
}

void
list_builtin_init ()
{
	list_builtin_eq_symbol = symbol_get ("EQ");
	list_builtin_test_symbol = symbol_get_packaged ("TEST", tre_package_keyword);
}
