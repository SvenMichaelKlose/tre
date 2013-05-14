/*
 * tré – Copyright (c) 2005–2008,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include <stdlib.h>

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "env.h"
#include "special.h"
#include "error.h"
#include "gc.h"
#include "debug.h"
#include "thread.h"
#include "xxx.h"

void
treenv_create (treptr a)
{
    TREATOM_ENV(a) = CONS(TRECONTEXT_ENV_CURRENT(), CONS(treptr_nil, treptr_nil));
}

#define PUSH_BINDING(x)	(TREATOM_BINDING(x) = CONS(TREATOM_VALUE(x), TREATOM_BINDING(x)))

void
treenv_bind (treptr la, treptr lv)
{
    treptr  arg;
    treptr  val;

    for (;la != treptr_nil && lv != treptr_nil; la = CDR(la), lv = CDR(lv)) {
        arg = CAR(la);
        val = CAR(lv);

		PUSH_BINDING(arg);
		TREATOM_VALUE(arg) = val;
    }

    if (la != treptr_nil)
        treerror (la, "arguments missing");
    if (lv != treptr_nil)
        treerror (lv, "too many arguments. Rest of forms");
}

void
treenv_bind_sloppy (treptr la, treptr lv)
{
    treptr  car;
    
    while (la != treptr_nil) {
        car = CAR(la);
        
		PUSH_BINDING(car);
        TREATOM_VALUE(car) = (lv != treptr_nil) ? CAR(lv) : treptr_nil;

        la = CDR(la);
        if (lv != treptr_nil)
            lv = CDR(lv);
    }
}

void
treenv_unbind (treptr la)
{
    treptr  bding;
    treptr  car;

    for (;la != treptr_nil; la = CDR(la)) {
        car = CAR(la);
        bding = TREATOM_BINDING(car);
        TREATOM_VALUE(car) = CAR(bding);
        TREATOM_BINDING(car) = CDR(bding);
        TRELIST_FREE_EARLY(bding);
    }
}

#endif /* #ifdef INTERPRETER */
