/*
 * tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>
 */

/*
#define BYTECODE_LOG
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
#include "eval.h"
#include "error.h"
#include "array.h"
#include "gc.h"
#include "util.h"
#include "builtin.h"
#include "special.h"
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
#include "symbol.h"
#include "function.h"

treptr treptr_jmp;
treptr treptr_cond;
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

    if (TREPTR_IS_NUMBER(v)) {
#ifdef BYTECODE_LOG
        printf ("set stack %d\n", TRENUMBER_INT(v));
#endif
        trestack_ptr[TRENUMBER_INT(v)] = value;
    } else if (v != treptr_nil) {
        TRESYMBOL_VALUE(v) = value;
    }

    *p = x;
}

treptr
trecode_get (treptr ** p)
{
    treptr  v;
    treptr  fun = treptr_nil;
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
#ifdef BYTECODE_LOG
printf ("GET: ");
treprint (v);
#endif

    if (v == treptr_nil) {
#ifdef BYTECODE_LOG
        printf ("NIL\n");
#endif
        /* Return NIL. */
    } else if (TREPTR_IS_NUMBER(v)) {
#ifdef BYTECODE_LOG
        printf ("stack %d\n", TRENUMBER_INT(v));
#endif
        v = trestack_ptr[TRENUMBER_INT(v)];
    } else if (v == treptr_quote) {
        v = *x++;
#ifdef BYTECODE_LOG
        printf ("quote %s\n", TRESYMBOL_NAME(v));
#endif
    } else if (v == treptr_vec) {
#ifdef BYTECODE_LOG
        printf ("vec\n");
#endif
        vec = trecode_get (&x);
        v = _TREVEC(vec, TRENUMBER_INT(*x++));
    } else if (v == treptr_closure) {
#ifdef BYTECODE_LOG
        printf ("closure\n");
#endif
        fun = *x++;
        tregc_push_secondary (fun);
        lex = trecode_get (&x);
        tregc_push_secondary (lex);
        v = CONS(treptr_closure, CONS(fun, lex));
        tregc_pop_secondary ();
        tregc_pop_secondary ();
    } else if (TREPTR_IS_SYMBOL(v) && TRESYMBOL_FUN(v)) {
#ifdef BYTECODE_LOG
        printf ("funcall ");
#endif
        fun = TRESYMBOL_FUN(v);
        if (TREPTR_IS_BUILTIN(fun)) {
#ifdef BYTECODE_LOG
            printf ("builtin ");
#endif
            if (v == treptr_cons) {
#ifdef BYTECODE_LOG
                printf ("cons\n");
#endif
                car = trecode_get (&x);
                tregc_push_secondary (car);
                cdr = trecode_get (&x);
                v = CONS(car, cdr);
                tregc_pop_secondary ();
            } else if (v == treptr_set_atom_fun) {
#ifdef BYTECODE_LOG
                printf ("set-atom-fun\n");
#endif
                trecode_set_place (&x, trecode_get (&x));
            } else {
#ifdef BYTECODE_LOG
                printf ("\n");
#endif
                num_args = TRENUMBER_INT(*x++);
                args = trecode_list (&x, num_args);
                tregc_push_secondary (args);
                v = treeval_xlat_function (treeval_xlat_builtin, fun, args, FALSE);
                tregc_pop_secondary ();
/*
                TRELIST_FREE_TOPLEVEL_EARLY(args);
*/
            }
        } else if (TREFUNCTION_BYTECODE(fun) != treptr_nil) {
#ifdef BYTECODE_LOG
            printf ("bytecode\n");
#endif
            tregc_push_secondary (fun);
            num_args = TRENUMBER_INT(*x++);
            old_sp = trestack_ptr;
            DOTIMES(i, num_args)
                *--old_sp = trecode_get (&x);
            trestack_ptr = old_sp;
#ifdef BYTECODE_LOG
car = v;
#endif
            v = trecode_exec (fun);
            trestack_ptr += num_args;
            tregc_pop_secondary ();
#ifdef BYTECODE_LOG
printf ("returned from %s\n", TRESYMBOL_NAME(car));
#endif
        } else
            treerror_norecover (v, "function expected in bytecode");
    } else if (v != treptr_nil && v != treptr_t)
        treerror_norecover (v, "Un%QUOTEd literal in bytecode.");
#ifdef BYTECODE_LOG
else
            printf ("NIL|T\n");
#endif
    *p = x;

    return v;
}

void
trecode_set (treptr ** x)
{
#ifdef BYTECODE_LOG
printf ("SET: ");
#endif
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

#ifdef BYTECODE_LOG
printf ("EXEC: ");
treprint (fun);
#endif

    fun = TREFUNCTION_BYTECODE(fun);
    if (TREPTR_IS_ARRAY(fun) == FALSE)
        treerror_norecover (fun, "bytecode function in form of an array expected");

    x = &TREARRAY_VALUES(fun)[2]; /* skip over argument definition and body */
    num_locals = TRENUMBER_INT(*x++);
    code = x;

    DOTIMES(i, num_locals)
        *--trestack_ptr = treptr_nil;

    while (1) {
        v = *x;
        if (v == treptr_jmp) {
            x++;
            dest = *x++;
            if (dest == treptr_nil) {
#ifdef BYTECODE_LOG
printf ("End of function.\n");
#endif
                break;
            }
#ifdef BYTECODE_LOG
printf ("Jump to %d.\n", TRENUMBER_INT(dest));
#endif
            x = &code[TRENUMBER_INT(dest)];
        } else if (v == treptr_cond) {
            x++;
            dest = *x++;
#ifdef BYTECODE_LOG
printf ("Conditional jump to %d.\n", TRENUMBER_INT(dest));
#endif
            if (trecode_get (&x) == treptr_nil) {
#ifdef BYTECODE_LOG
printf ("Jump to %d.\n", TRENUMBER_INT(dest));
#endif
                x = &code[TRENUMBER_INT(dest)];
            }
        } else if (v == treptr_set_vec) {
#ifdef BYTECODE_LOG
printf ("Set vector.\n");
#endif
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

    if (!(TREPTR_IS_FUNCTION(fun) || TREPTR_IS_MACRO(fun)))
        treerror_norecover (fun, "function expected");

    if (TREFUNCTION_BYTECODE(fun) == treptr_nil)
        treerror_norecover (fun, "function has no bytecode");

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
    treptr_set_vec = treatom_get ("%BC-SET-VEC", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_set_vec);
    treptr_jmp = treatom_get ("%%GO", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_jmp);
    treptr_cond = treatom_get ("%%GO-NIL", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_cond);
    treptr_vec = treatom_get ("%VEC", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_vec);
    treptr_set_atom_fun = treatom_get ("%SET-ATOM-FUN", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_set_atom_fun);
    treptr_cons = treatom_get ("CONS", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_cons);
    treptr_quote = treatom_get ("%QUOTE", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_quote);
    treptr_closure = treatom_get ("%CLOSURE", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_closure);
    treptr_quote = treatom_get ("%QUOTE", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treptr_quote);
}
