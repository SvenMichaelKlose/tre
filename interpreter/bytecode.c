/*
 * tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "number.h"
#include "list.h"
#include "string2.h"
#include "eval.h"
#include "error.h"
#include "array.h"
#include "diag.h"
#include "gc.h"
#include "util.h"
#include "builtin.h"
#include "special.h"
#include "env.h"
#include "io.h"
#include "main.h"
#include "symbol.h"
#include "print.h"
#include "thread.h"
#include "image.h"
#include "alloc.h"
#include "compiled.h"
#include "bytecode.h"

#include <string.h>
#include <strings.h>
#include <stdlib.h>

treptr treptr_set;
treptr treptr_funcall;
treptr treptr_builtin;
treptr treptr_jmp;
treptr treptr_cond;
treptr treptr_stack;
treptr treptr_vec;

treptr
trecode_get (treptr ** p)
{
    treptr v;
    treptr fun;
    treptr args;
    treptr * x = *p;
    unsigned num_args;
    unsigned i;

    v = *x++;
printf ("value ");
treprint (v);
    if (v == treptr_stack)
        v = trestack_ptr[TRENUMBER_INT(*x++)];
    else if (v == treptr_vec)
        v = _TREVEC(TRENUMBER_INT(*x++), TRENUMBER_INT(*x++));
    else if (v == treptr_funcall) {
printf ("funcall\n");
treprint (*x);
        treprint (TREATOM_FUN(fun));
        fun = *x++;
        if (fun == treptr_builtin) {
printf ("builtin\n");
            fun = *x++;
            args = CONS(fun, trecode_get (&x));
            tregc_push (args);
            v = trebuiltin (fun, args);
            tregc_pop ();
        } else {
            num_args = TRENUMBER_INT(TREARRAY_RAW(TREATOM_FUN(fun))[0]);
    printf ("num args: %d\n", num_args);
            DOTIMES(i, num_args)
                *trestack_ptr++ = trecode_get (&x);
treprint (*x);
            v = trecode_exec (*x++);
            trestack_ptr -= num_args;
        }
    }
    *p = x;
    return v;
}

treptr *
trecode_set (treptr * x)
{
    treptr v = trecode_get (&x);
    treptr p = *x++;
printf ("place ");
treprint (p);

    if (p == treptr_stack)
        trestack_ptr[TRENUMBER_INT(*x++)] = v;
    else if (p == treptr_vec)
        _TREVEC(TRENUMBER_INT(*x++), TRENUMBER_INT(*x++)) = v;
    else if (p == treptr_nil)
        return x;
    else
        treerror_norecover (p, "set: illegal bytecode place");

    return x;
}

treptr
trecode_exec (treptr fun)
{
    treptr * code;
    treptr * x;
    treptr dest;
    treptr v;
    unsigned num_locals;
    unsigned i = 0;

printf ("Executing bytecode function.\n");
    if (TREPTR_IS_ARRAY(fun) == FALSE)
        treerror_norecover (fun, "bytecode array function expected");
    x = &TREARRAY_RAW(fun)[1];
    num_locals = TRENUMBER_INT(*x++);
    code = x;

    DOTIMES(i, num_locals)
        *trestack_ptr++ = treptr_nil;

    while (1) {
        v = *x++;
        if (v == treptr_set) {
            x = trecode_set (x);
        } else if (v == treptr_jmp) {
            dest = *x++;
            if (dest == treptr_nil) {
                trestack_ptr -= num_locals;
                break;
            }
            x = &code[TRENUMBER_INT(dest)];
        } else if (v == treptr_cond) {
            if (trecode_get (&x) != treptr_nil)
                x++;
            else
                x = &code[TRENUMBER_INT(*x)];
        } else
            treerror_norecover (v, "illegal bytecode instruction");
    }

    v = *trestack_ptr;
    trestack_ptr -= num_locals;
    return v;
}

void
trecode_init ()
{
    treptr_set = treatom_get ("%BC-SET", TRECONTEXT_PACKAGE());                                                                                
    EXPAND_UNIVERSE(treptr_set);
    treptr_funcall = treatom_get ("%BC-FUNCALL", TRECONTEXT_PACKAGE());                                                                                
    EXPAND_UNIVERSE(treptr_funcall);
    treptr_builtin = treatom_get ("%BC-BUILTIN", TRECONTEXT_PACKAGE());                                                                                
    EXPAND_UNIVERSE(treptr_builtin);
    treptr_jmp = treatom_get ("%%VM-GO", TRECONTEXT_PACKAGE());                                                                                
    EXPAND_UNIVERSE(treptr_jmp);
    treptr_cond = treatom_get ("%%VM-GO-NIL", TRECONTEXT_PACKAGE());                                                                                
    EXPAND_UNIVERSE(treptr_cond);
    treptr_stack = treatom_get ("%STACK", TRECONTEXT_PACKAGE());                                                                                
    EXPAND_UNIVERSE(treptr_stack);
    treptr_vec = treatom_get ("%VEC", TRECONTEXT_PACKAGE());                                                                                
    EXPAND_UNIVERSE(treptr_vec);
}
