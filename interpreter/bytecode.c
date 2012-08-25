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
treptr treptr_special;
treptr treptr_jmp;
treptr treptr_cond;
treptr treptr_stack;
treptr treptr_vec;
treptr treptr_set_vec;
treptr treptr_set_atom_fun;
treptr treptr_cons;
treptr treptr_quote;
treptr treptr_apply;
treptr treptr_funref;

treptr trecode_get (treptr ** p);

treptr
trecode_list (treptr ** p, int len)
{
    treptr  l = tre_make_queue ();
    treptr  v;
    treptr  * x = *p;
    int     i;

    tregc_push (l);
    DOTIMES(i, len) {
        v = trecode_get (&x);
        printf ("Elm %d: ", i);
        treprint (v);
        tre_enqueue (l, v);
    }
    tregc_pop ();
    *p = x;

    return CDR(l);
}

void
trecode_set_place (treptr ** p, treptr value)
{
    treptr * x = *p;
    treptr v = *x++;

    printf ("Place ");
    treprint (v);

    if (v == treptr_stack) {
        treprint (*x); fflush (stdout);
        trestack_ptr[TRENUMBER_INT(*x++)] = value;
    } else if (v != treptr_nil)
        TREATOM_VALUE(v) = value;

    printf ("\n");
    *p = x;
}

void
trecode_set_fun (treptr ** p, treptr value)
{
    treptr * x = *p;
    treptr v = *x++;

    printf ("fun place ");
    treprint (v);

    if (v == treptr_stack) {
        treprint (*x); fflush (stdout);
        TREATOM_FUN(trestack_ptr[TRENUMBER_INT(*x++)]) = value;
    } else if (v != treptr_nil)
        TREATOM_FUN(v) = value;

    *p = x;
}

treptr
trecode_call (treptr fun, treptr args)
{
    treptr i;
    treptr v;
    treptr num_args = 0;

    DOLIST(i, args) {
        *--trestack_ptr = CAR(i);
        num_args++;
    }
    v = trecode_exec (fun);
    trestack_ptr += num_args;
    return v;
}

treptr
trecode_get (treptr ** p)
{
    treptr  v;
    treptr  fun;
    treptr  funtype;
    treptr  args;
    treptr  car;
    treptr  cdr;
    treptr  vec;
    treptr  lex;
    treptr  * x = *p;
    int     num_args;
    int     i;
    int     j;

    v = *x++;
    printf ("value "); treprint (v); fflush (stdout);
    if (v == treptr_stack) {
        treprint (*x); fflush (stdout);
        v = trestack_ptr[TRENUMBER_INT(*x++)];
    } else if (v == treptr_vec) {
        vec = trecode_get (&x);
        v = _TREVEC(vec, TRENUMBER_INT(*x++));
    } else if (v == treptr_quote) {
        printf ("quote "); treprint (*x); fflush (stdout);
        v = *x++;
    } else if (v == treptr_funcall) {
        printf ("funcall "); treprint (*x); fflush (stdout);
        fun = *x++;
        if (fun == treptr_builtin || fun == treptr_special) {
            funtype = fun;
            printf ("builtin "); fflush (stdout);
            fun = *x++;
            treprint (fun); fflush (stdout);
            if (fun == treptr_cons) {
                /* Special treatment to avoid back-end workarounds. */
                printf ("builtin cons\n"); fflush (stdout);
                car = trecode_get (&x);
                tregc_push (car);
                cdr = trecode_get (&x);
                v = CONS(car, cdr);
                tregc_pop ();
            } else if (fun == treptr_set_atom_fun) {
                printf ("builtin atom fun setter\n"); fflush (stdout);
                trecode_set_place (&x, trecode_get (&x));
            } else {
                num_args = TRENUMBER_INT(*x++);
                printf ("builtin std num args: %d\n", num_args); fflush (stdout);
                args = trecode_list (&x, num_args);
                tregc_push (args);
                v = (fun == treptr_apply) ?
                    trespecial_apply_compiled (CAR(args)) :
                    treeval_xlat_function (funtype == treptr_builtin ? treeval_xlat_builtin : treeval_xlat_spec, fun, CONS(fun, args), FALSE);
                tregc_pop ();
            }
        } else if (TREPTR_IS_ATOM(fun) && TREPTR_IS_ARRAY(TREATOM_FUN(fun))) {
            num_args = TRENUMBER_INT(*x++);
            printf ("num args: %d\n", num_args); fflush (stdout);
            j = -1;
            DOTIMES(i, num_args)
                trestack_ptr[j--] = trecode_get (&x);
            trestack_ptr -= num_args;
            v = trecode_exec (TREATOM_FUN(fun));
            trestack_ptr += num_args;
        } else 
            treerror_norecover (fun, "tried to call an unsupported function type in bytecode");
    } else if (v == treptr_funref) {
        printf ("lexical funref\n"); fflush (stdout);
        fun = TREATOM_FUN(*x++);
        tregc_push (fun);
        lex = trecode_get (&x);
        tregc_push (lex);
        v = CONS(treptr_funref, CONS(fun, CONS(lex, treptr_nil)));
        tregc_pop ();
        tregc_pop ();
    } else if (TREPTR_IS_VARIABLE(v))
        v = TREATOM_VALUE(v);
    printf ("Return value: "); treprint (v);
    *p = x;
    return v;
}

treptr *
trecode_set (treptr * x)
{
    trecode_set_place (&x, trecode_get (&x));
    return x;
}

treptr
trecode_exec (treptr fun)
{
    treptr   * code;
    treptr   * x;
    treptr   dest;
    treptr   v;
    unsigned num_locals;
    unsigned i = 0;
    int      vec;
    int      vecindex;

    printf ("Executing bytecode function.\n");
    if (TREPTR_IS_ARRAY(fun) == FALSE)
        treerror_norecover (fun, "bytecode array function expected");
    x = &TREARRAY_RAW(fun)[1];
    num_locals = TRENUMBER_INT(*x++);
    code = x;
    treprint (fun);

    DOTIMES(i, num_locals)
        *--trestack_ptr = treptr_nil;

    while (1) {
        v = *x++;
        printf ("Instruction ");
        treprint (v);
        if (v == treptr_set) {
            x = trecode_set (x);
        } else if (v == treptr_jmp) {
            printf ("=============== function return =============\n"); fflush (stdout);
            dest = *x++;
            if (dest == treptr_nil)
                break;
            x = &code[TRENUMBER_INT(dest)];
        } else if (v == treptr_cond) {
            if (trecode_get (&x) != treptr_nil) {
                printf ("Skipping jump.\n");
                x++;
            } else {
                printf ("Jumping to %d.\n", TRENUMBER_INT(*x));
                x = &code[TRENUMBER_INT(*x)];
            }
        } else if (v == treptr_set_vec) {
            vec = trecode_get (&x);
            i = TRENUMBER_INT(*x++);
            v = _TREVEC(vec, i) = trecode_get (&x);
        } else
            treerror_norecover (v, "illegal bytecode instruction");
    }

    v = *trestack_ptr;
    trestack_ptr += num_locals;
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
    treptr_special = treatom_get ("%BC-SPECIAL", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_special);
    treptr_jmp = treatom_get ("%%VM-GO", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_jmp);
    treptr_cond = treatom_get ("%%VM-GO-NIL", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_cond);
    treptr_stack = treatom_get ("%STACK", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_stack);
    treptr_vec = treatom_get ("%VEC", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_vec);
    treptr_set_vec = treatom_get ("%SET-VEC", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_set_vec);
    treptr_set_atom_fun = treatom_get ("%SET-ATOM-FUN", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_set_atom_fun);
    treptr_cons = treatom_get ("CONS", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_cons);
    treptr_quote = treatom_get ("%QUOTE", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_quote);
    treptr_apply = treatom_get ("APPLY", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_apply);
    treptr_funref = treatom_get ("%FUNREF", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_funref);
}
