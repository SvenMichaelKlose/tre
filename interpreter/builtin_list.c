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

#include "builtin_atom.h"

treptr trelist_builtin_eq_symbol;
treptr trelist_builtin_test_symbol;

treptr
trelist_builtin_cons (treptr list)
{
    TRELIST_DEFREGS();
    trearg_get2 (&car, &cdr, list);
    return CONS(car, cdr);
}

treptr
trelist_builtin_car (treptr x)
{
    treptr arg = trearg_get (x);
    RETURN_NIL(arg);
    return CAR(arg);
}

treptr
trelist_builtin_cdr (treptr x)
{
    treptr arg = trearg_get (x);
    RETURN_NIL(arg);
    return CDR(arg);
}

treptr
trelist_builtin_cpr (treptr x)
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
trelist_builtin_rplaca (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACA(cons, new);
    return cons;
}

treptr
trelist_builtin_rplacd (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACD(cons, new);
    return cons;
}

treptr
trelist_builtin_rplacp (treptr list)
{
    TRELISTARG_GET2(cons, new, list);
    RPLACP(cons, new);
    return cons;
}

treptr
trelist_consp (treptr x)
{
    if (ATOMP(x))
        return treptr_nil;
    return treptr_t;
}

treptr
trelist_builtin_consp (treptr list)
{
    return trelist_consp (CAR(list));
}

void
trelist_builtin_init ()
{
	trelist_builtin_eq_symbol = symbol_get ("EQ");
	trelist_builtin_test_symbol = symbol_get_packaged ("TEST", tre_package_keyword);
}
