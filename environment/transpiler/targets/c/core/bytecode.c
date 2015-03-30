/*
 * tré – Copyright (c) 2012–2015 Sven Michael Klose <pixel@copei.de>
 */

#include <string.h>
#include <strings.h>
#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "number.h"
#include "cons.h"
#include "list.h"
#include "string2.h"
#include "error.h"
#include "array.h"
#include "gc.h"
#include "util.h"
#include "builtin.h"
#include "stream.h"
#include "main.h"
#include "symtab.h"
#include "print.h"
#include "thread.h"
#include "image.h"
#include "alloc.h"
#include "compiled.h"
#include "bytecode.h"
#include "queue.h"
#include "function.h"
#include "symbol.h"

treptr treptr_jmp;
treptr treptr_cond;
treptr treptr_cond_not_nil;
treptr treptr_vec;
treptr treptr_set_vec;
treptr treptr_set_atom_fun;
treptr treptr_cons;
treptr treptr_quote;
treptr treptr_closure;
treptr treptr_quote;

treptr trecode_get (treptr ** p);

treptr
trecode_list (treptr ** x, int len)
{
    treptr  l = tre_make_queue ();
    treptr  v;
    int     i;

    tregc_push_secondary (l);
    DOTIMES(i, len) {
        v = trecode_get (x);
        tre_enqueue (l, v);
    }
    tregc_pop_secondary ();

    return CDR(l);
}

void
trecode_set_place (treptr ** p, treptr value)
{
    treptr * x = *p;
    treptr v = *x++;

    if (NUMBERP(v)) {
        trestack_ptr[TRENUMBER_INT(v)] = value;
    } else if (NOT_NIL(v)) {
        SYMBOL_VALUE(v) = value;
    }

    *p = x;
}

treptr
trecode_get (treptr ** p)
{
    treptr  v;
    treptr  fun = NIL;
    treptr  args;
    treptr  car;
    treptr  cdr;
    treptr  vec;
    treptr  lex;
    treptr  * old_sp;
    treptr  * x = *p;
    int     num_args;
    int     i;

    v = *x++;

    if (NOT(v)) {
        /* Return NIL. */
    } else if (NUMBERP(v)) {
        v = trestack_ptr[TRENUMBER_INT(v)];
    } else if (v == treptr_quote) {
        v = *x++;
    } else if (v == treptr_vec) {
        vec = trecode_get (&x);
        v = _TREVEC(vec, TRENUMBER_INT(*x++));
    } else if (v == treptr_closure) {
        fun = *x++;
        tregc_push_secondary (fun);
        lex = trecode_get (&x);
        tregc_push_secondary (lex);
        v = CONS(treptr_closure, CONS(fun, lex));
        tregc_pop_secondary ();
        tregc_pop_secondary ();
    } else if (SYMBOLP(v) && SYMBOL_FUNCTION(v)) {
        fun = SYMBOL_FUNCTION(v);
        if (BUILTINP(fun)) {
            if (v == treptr_cons) {
                car = trecode_get (&x);
                tregc_push_secondary (car);
                cdr = trecode_get (&x);
                v = CONS(car, cdr);
                tregc_pop_secondary ();
            } else if (v == treptr_set_atom_fun) {
                treerror_norecover (v, "%SET-ATOM-FUN shouldn't be in the bytecode interpreter at all");
                trecode_set_place (&x, trecode_get (&x));
            } else {
                num_args = TRENUMBER_INT(*x++);
                args = trecode_list (&x, num_args);
                tregc_push_secondary (args);
                v = eval_xlat_function (eval_xlat_builtin, fun, args, FALSE);
                tregc_pop_secondary ();
            }
        } else if (NOT_NIL(FUNCTION_BYTECODE(fun))) {
            tregc_push_secondary (fun);
            num_args = TRENUMBER_INT(*x++);
            old_sp = trestack_ptr;
            DOTIMES(i, num_args)
                *--old_sp = trecode_get (&x);
            trestack_ptr = old_sp;
            v = trecode_exec (fun);
            trestack_ptr += num_args;
            tregc_pop_secondary ();
        }
    } 
#ifdef TRE_HAVE_BYTECODE_ASSERTIONS
      else if (NOT_NIL(v) && v != treptr_t)
        treerror_norecover (v, "Un%QUOTEd literal in bytecode.");
#endif
    *p = x;

    return v;
}

void
trecode_set (treptr ** x)
{
    trecode_set_place (x, trecode_get (x));
}

treptr
trecode_exec (treptr fun)
{
    treptr   * code;
    treptr   * x;
    treptr   dest;
    treptr   v;
    int      num_locals;
    int      i;
    int      vec;

    fun = FUNCTION_BYTECODE(fun);
#ifdef TRE_HAVE_BYTECODE_ASSERTIONS
    if (TREPTR_IS_ARRAY(fun) == FALSE)
        treerror_norecover (fun, "Bytecode function in form of an array expected.");
#endif

    x = &TREARRAY_VALUES(fun)[2]; /* skip over argument definition and body */
    num_locals = TRENUMBER_INT(*x++);
    code = x;

    DOTIMES(i, num_locals)
        *--trestack_ptr = NIL;

    while (1) {
        v = *x;
        if (v == treptr_jmp) {
            x++;
            dest = *x++;
            if (NOT(dest))
                break;
            x = &code[TRENUMBER_INT(dest)];
        } else if (v == treptr_cond) {
            x++;
            dest = *x++;
            if (NOT(trecode_get (&x)))
                x = &code[TRENUMBER_INT(dest)];
        } else if (v == treptr_cond_not_nil) {
            x++;
            dest = *x++;
            if (!NOT(trecode_get (&x)))
                x = &code[TRENUMBER_INT(dest)];
        } else if (v == treptr_set_vec) {
            x++;
            vec = trecode_get (&x);
            tregc_push_secondary (vec);
            i = TRENUMBER_INT(*x++);
            v = _TREVEC(vec, i) = trecode_get (&x);
            tregc_pop_secondary ();
        } else
            trecode_set (&x);
    }

    v = *trestack_ptr;
    trestack_ptr += num_locals;
    return v;
}

treptr
trecode_call (treptr fun, treptr args)
{
    treptr i;
    treptr v;
    treptr num_args = 0;

#ifdef TRE_HAVE_BYTECODE_ASSERTIONS
    if (!(TREPTR_IS_FUNCTION(fun) || TREPTR_IS_MACRO(fun)))
        treerror_norecover (fun, "Function expected.");

    if (NOT(FUNCTION_BYTECODE(fun)))
        treerror_norecover (fun, "Function has no bytecode.");
#endif

    tregc_push_secondary (fun);
    DOLIST(i, args) {
        *--trestack_ptr = CAR(i);
        num_args++;
    }
    v = trecode_exec (fun);
    trestack_ptr += num_args;
    tregc_pop_secondary ();

    return v;
}

void
trecode_init ()
{
    treptr_set_vec = symbol_get ("%BC-SET-VEC");
    EXPAND_UNIVERSE(treptr_set_vec);
    treptr_jmp = symbol_get ("%%GO");
    EXPAND_UNIVERSE(treptr_jmp);
    treptr_cond = symbol_get ("%%GO-NIL");
    EXPAND_UNIVERSE(treptr_cond);
    treptr_cond_not_nil = symbol_get ("%%GO-NOT-NIL");
    EXPAND_UNIVERSE(treptr_cond_not_nil);
    treptr_vec = symbol_get ("%VEC");
    EXPAND_UNIVERSE(treptr_vec);
    treptr_set_atom_fun = symbol_get ("%SET-ATOM-FUN");
    EXPAND_UNIVERSE(treptr_set_atom_fun);
    treptr_cons = symbol_get ("CONS");
    EXPAND_UNIVERSE(treptr_cons);
    treptr_quote = symbol_get ("%QUOTE");
    EXPAND_UNIVERSE(treptr_quote);
    treptr_closure = symbol_get ("%%CLOSURE");
    EXPAND_UNIVERSE(treptr_closure);
    treptr_quote = symbol_get ("%QUOTE");
    EXPAND_UNIVERSE(treptr_quote);
}
