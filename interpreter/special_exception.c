/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#include "ptr.h"
#include "cons.h"
#include "error.h"
#include "io.h"
#include "main.h"
#include "eval.h"
#include "special.h"
#include "exception.h"

treptr
trespecial_catch (treptr x)
{
    treptr ret;

    printf ("CATCH\n");
    if (NOT(x))
        treerror (x, "Catcher expected.");
    if (NOT(CDR(x)))
        treerror (x, "Body expected.");

    treexception_catch_enter ();
    catchers[current_catcher].catcher = CAR(x);
    if (setjmp (catchers[current_catcher].jmp)) {
        treexception_catch_leave ();
        ret = treeval (catchers[current_catcher + 1].catcher);
    } else {
        ret = trespecial_progn (CDR(x));
        treexception_catch_leave ();
    }
    return ret;
}

treptr
trespecial_throw (treptr x)
{
    (void) x;

    treexception_throw ();

    /*NOTREACHED*/
    return treptr_nil;
}
