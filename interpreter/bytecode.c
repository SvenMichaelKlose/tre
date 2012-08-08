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
#include "queue.h"

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
treptr treptr_cons;
treptr treptr_quote;

treptr
trecode_get (treptr ** p)
{
    treptr v;
    treptr fun;
    treptr args;
    treptr car;
    treptr cdr;
    treptr * x = *p;
    int num_args;
    int i;

    v = *x++;
    printf ("value "); treprint (v); fflush (stdout);
    if (v == treptr_stack)
        v = trestack_ptr[TRENUMBER_INT(*x++)];
    else if (v == treptr_vec)
        v = _TREVEC(TRENUMBER_INT(*x++), TRENUMBER_INT(*x++));
    else if (v == treptr_quote)
        v = *x++;
    else if (v == treptr_funcall) {
        printf ("funcall\n"); treprint (*x); fflush (stdout);
        fun = *x++;
        if (fun == treptr_builtin) {
            printf ("builtin\n"); fflush (stdout);
            fun = *x++;
            treprint (fun); fflush (stdout);
            if (fun == treptr_cons) {
                /* Special treatment to avoid back-end workarounds. */
                printf ("builtin cons\n"); fflush (stdout);
                car = trecode_get (&x);
                tregc_push (CONS(car, cdr));
            } else {
                printf ("builtin std"); fflush (stdout);
                args = tre_make_queue ();
                tregc_push (args);
                num_args = TRENUMBER_INT(*x++);
                printf ("num args: %d\n", num_args);
                DOTIMES(i, num_args) {
                    v = trecode_get (&x);
                    printf ("arg %d: ", i); treprint (v); fflush (stdout);
                    tre_enqueue (args, v);
                }
                tregc_pop ();
                args = CDR(args);
                printf ("args len after %d: ", trelist_length (args)); fflush (stdout);
                tregc_push (args);
            }
            v = treeval_xlat_function (treeval_xlat_builtin, fun, CONS(fun, args), FALSE);
            tregc_pop ();
        } else {
            num_args = TRENUMBER_INT(TREARRAY_RAW(TREATOM_FUN(fun))[0]);
            printf ("num args: %d\n", num_args); fflush (stdout);
            DOTIMES(i, num_args)
                *trestack_ptr++ = trecode_get (&x);
            treprint (*x); fflush (stdout);
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
    treprint (fun);

    DOTIMES(i, num_locals)
        *trestack_ptr++ = treptr_nil;

    while (1) {
        v = *x++;
        printf ("Instruction ");
        treprint (v);
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
            if (trecode_get (&x) != treptr_nil) {
                printf ("Skipping jump.\n");
                x++;
            } else {
                printf ("Jumping to %d.\n", TRENUMBER_INT(*x));
                x = &code[TRENUMBER_INT(*x)];
            }
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
    treptr_cons = treatom_get ("CONS", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_cons);
    treptr_quote = treatom_get ("QUOTE", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_quote);
}
