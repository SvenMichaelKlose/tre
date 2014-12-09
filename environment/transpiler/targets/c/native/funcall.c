/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <stdio.h>
#include <ffi.h>

#include "config.h"
#include "ptr.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "error.h"
#include "gc.h"
#include "bytecode.h"
#include "array.h"
#include "thread.h"
#include "builtin.h"
#include "funcall.h"
#include "function.h"
#include "symtab.h"
#include "backtrace.h"
#include "symbol.h"

#include "builtin_atom.h"

#define CLOSURE_FUNCTION(x)  CAR(CDR(x))
#define CLOSURE_LEXICALS(x)  CDR(CDR(x))

treptr
funcall_ffi (void * fun, treptr x)
{
    ffi_cif     cif;
    ffi_type ** args;
    treptr *    refs;
    void **     values;
    treptr      rc;
    int         i;
    int         len = list_length (x) + 1;

    tregc_push (x);
    args = malloc (sizeof (ffi_type *) * len);
    refs = malloc (sizeof (treptr) * len);
    values = malloc (sizeof (void *) * len);
    for (i = 0; NOT_NIL(x); i++, x = CDR(x)) {
        args[i] = &ffi_type_ulong;
        refs[i] = CAR(x);
        values[i] = &refs[i];
    }

    if (ffi_prep_cif (&cif, FFI_DEFAULT_ABI, i, &ffi_type_ulong, args) == FFI_OK)
        ffi_call (&cif, fun, &rc, values);
    else
        treerror_norecover (NIL, "libffi: cif is not O.K.");

    free (args);
    free (refs);
    free (values);
    tregc_pop ();

    return rc;
}

treptr
funcall_c (treptr func, treptr args, bool do_eval)
{
    treptr ret;
    treptr a = do_eval ? eval_args (args) : args;

    tregc_push (a);
    ret = FUNCTION_NATIVE_EXPANDER(func) ?
              funcall_ffi (FUNCTION_NATIVE_EXPANDER(func), CONS(a, NIL)) :
              funcall_ffi (FUNCTION_NATIVE(func), a);
    tregc_pop ();

    return ret;
}


treptr
funcall_bytecode (treptr func, treptr args, treptr argdef, bool do_eval)
{
    treptr  expforms;
    treptr  expvals;
	treptr  result;

    /* XXX Nah! Needs expanders like in funcall_c(). */
   	trearg_expand (&expforms, &expvals, argdef, args, do_eval);
   	tregc_push (expvals);
    result = trecode_call (func, expvals);
	tregc_pop ();

	return result;
}

treptr
funcall_compiled (treptr func, treptr args, bool do_eval)
{
    treptr v;

    tregc_push (args);
    trebacktrace_push (NIL);
    v = NOT(FUNCTION_BYTECODE(func)) ?
            funcall_c (func, args, do_eval) :
            funcall_bytecode (func, args, TREARRAY_VALUES(FUNCTION_BYTECODE(func))[0], do_eval);
    trebacktrace_pop ();
    tregc_pop ();

    return v;
}

treptr
funcall_interpreted (treptr func, treptr args)
{
    if (FUNCTIONP(func) || MACROP(func))
        return eval_funcall (func, args, FALSE);
    if (BUILTINP(func))
        return eval_xlat_function (eval_xlat_builtin, func, args, FALSE);
    if (SPECIALP(func))
        return trespecial (func, args);
    return treerror (func, "Function expected.");
}

treptr
funcall (treptr func, treptr args)
{
    treptr v;

	if (is_compiled_closure (func))
		return funcall_compiled (SYMBOL_FUNCTION(CLOSURE_FUNCTION(func)),
		                            CONS(CLOSURE_LEXICALS(func), args),
                                    FALSE);
	if (COMPILED_FUNCTIONP(func))
		return funcall_compiled (func, args, FALSE);

    tregc_push (args);
    trebacktrace_push (BUILTINP(func) ? func : FUNCTION_NAME(func));
    v = funcall_interpreted (func, args);
    trebacktrace_pop ();
    tregc_pop ();

    return v;
}
