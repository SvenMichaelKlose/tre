/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
 */

#include "atom.h"
#include "xxx.h"
#include "cons.h"
#include "error.h"
#include "apply.h"
#include "list.h"
#include "eval.h"
#include "argument.h"

treptr
trebuiltin_apply_args (treptr list)
{
    treptr  i;
    treptr  last;

    RETURN_NIL(list); /* No arguments. */

    /* Handle single argument. */
    if (NOT(CDR(list))) {
        list = CAR(list);
        if (ATOMP(list) && NOT_NIL(list))
            goto error;
        return list;
    }

    /* Handle two or more arguments. */
    DOLIST(i, list) {
        if (NOT_NIL(CDDR(i)))
            continue;

        last = CADR(i);
        if (ATOMP(last) && NOT_NIL(last))
            goto error;

        RPLACD(i, last);
        break;
    }

    return list;
                                                                                                                                                               
error:
    return treerror (list, "Last argument must be a list - please provide a new argument list.");
}

treptr
trebuiltin_apply (treptr list)
{
    return NOT(list) ?
               treerror (list, "Arguments expected.") :
               trefuncall (CAR(list), trebuiltin_apply_args (trelist_copy (CDR(list))));
}

treptr
trebuiltin_funcall (treptr list)
{
    return NOT(list) ?
               treerror (list, "Arguments expected.") :
               trefuncall (CAR(list), CDR(list));
}

treptr
trebuiltin_eval (treptr list)
{
    return eval (trearg_get (list));
}
