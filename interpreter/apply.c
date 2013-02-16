/*
 * tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "ptr.h"
#include "alloc.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "eval.h"
#include "builtin.h"
#include "error.h"
#include "gc.h"
#include "debug.h"
#include "thread.h"
#include "env.h"
#include "argument.h"
#include "xxx.h"
#include "eval.h"
#include "bytecode.h"
#include "array.h"
#include "io.h"
#include "main.h"
#include "print.h"
#include "special.h"
#include "apply.h"

#include "builtin_debug.h"
#include "builtin_atom.h"

#include <stdio.h>
#include <ffi.h>

#define CLOSURE_FUNCTION(x)  CAR(CDR(x))
#define CLOSURE_LEXICALS(x)  CDR(CDR(x))

treptr treatom_closure;

bool
trebuiltin_is_compiled_closure (treptr x)
{
	return TREPTR_IS_CONS(x) && CAR(x) == treatom_closure;
}

treptr
trebuiltin_call_compiled (void * fun, treptr x)
{
	ffi_cif cif;
	ffi_type **args;
	treptr *refs;
	void **values;
	treptr rc;
	int i;
    int len = trelist_length (x) + 1;

    args = trealloc (sizeof (ffi_type *) * len);
    refs = trealloc (sizeof (treptr) * len);
    values = trealloc (sizeof (void *) * len);
	for (i = 0; x != treptr_nil; i++, x = CDR(x)) {
		args[i] = &ffi_type_ulong;
		refs[i] = CAR(x);
		values[i] = &refs[i];
	}

	if (ffi_prep_cif(&cif, FFI_DEFAULT_ABI, i, &ffi_type_ulong, args) == FFI_OK) {
		ffi_call(&cif, fun, &rc, values);
	} else
        treerror_norecover (treptr_nil, "libffi: cif is not O.K.");

    trealloc_free (args);
    trealloc_free (refs);
    trealloc_free (values);
	return rc;
}

treptr
treeval_compiled_expr_c (treptr func, treptr args, treptr argdef, bool do_eval)
{
    treptr  expforms;
    treptr  expvals;
	treptr  result;

   	tregc_push (args);
   	trearg_expand (&expforms, &expvals, argdef, args, do_eval);
   	tregc_push (expvals);

    result = trebuiltin_call_compiled (TREATOM_COMPILED_FUN(func), expvals);

	tregc_pop ();
	tregc_pop ();

	return result;
}


treptr
treeval_compiled_expr_bc (treptr func, treptr args, treptr argdef, bool do_eval)
{
    treptr  expforms;
    treptr  expvals;
	treptr  result;

   	tregc_push (args);
   	trearg_expand (&expforms, &expvals, argdef, args, do_eval);
   	tregc_push (expvals);

    result = trecode_call (func, expvals);

	tregc_pop ();
	tregc_pop ();

	return result;
}

treptr
trefuncall_compiled (treptr func, treptr args, bool do_eval)
{
    return TREPTR_IS_ARRAY(func) ?
               treeval_compiled_expr_bc (func, args, TREARRAY_RAW(func)[0], do_eval) :
               (TREATOM_COMPILED_EXPANDER(func) ?
                    trebuiltin_call_compiled (TREATOM_COMPILED_EXPANDER(func),
                                              CONS(do_eval ? treeval_args (args) : args, treptr_nil)) :
                    treeval_compiled_expr_c (func, args, CAR(TREATOM_VALUE(func)), do_eval));
}

treptr
trefuncall (treptr func, treptr args)
{
	if (trebuiltin_is_compiled_closure (func))
		return trefuncall_compiled (TREATOM_FUN(CLOSURE_FUNCTION(func)),
		                            CONS(CLOSURE_LEXICALS(func), args),
                                    FALSE);
	if (IS_COMPILED_FUN(func))
		return trefuncall_compiled (func, args, FALSE);
    if (TREPTR_IS_FUNCTION(func) || TREPTR_IS_MACRO(func))
        return treeval_funcall (func, args, FALSE);
    if (TREPTR_IS_BUILTIN(func))
        return treeval_xlat_function (treeval_xlat_builtin, func, args, FALSE);
    if (TREPTR_IS_SPECIAL(func))
        return trespecial (func, args);
    return treerror (func, "function expected");
}

void
treapply_init ()
{
    treatom_closure = treatom_get ("%CLOSURE", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treatom_closure);
}
