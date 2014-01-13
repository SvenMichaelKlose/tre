/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#include "ptr.h"
#include "cons.h"
#include "error.h"
#include "io.h"
#include "main.h"
#include "exception.h"

trecatch catchers[TRE_NUM_CATCHERS];
int current_catcher = 0;

void
treexception_catch_leave ()
{
    trestack_ptr = catchers[current_catcher--].gc_stack;
}

void
treexception_catch_enter ()
{
    catchers[++current_catcher].gc_stack = trestack_ptr;
}

void
treexception_throw ()
{
    if (current_catcher > 0) {
        trestack_ptr = catchers[current_catcher].gc_stack;
        longjmp (catchers[current_catcher].jmp, -1);
    }
    treerror_norecover (treptr_invalid, "Uncaught exception.");
}
