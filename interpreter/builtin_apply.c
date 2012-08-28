/*
 * tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "ptr.h"
#include "alloc.h"
#include "atom.h"
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

#include "builtin_apply.h"
#include "builtin_debug.h"
#include "builtin_atom.h"

#include <stdio.h>
#include <ffi.h>

#define FUNREF_FUNCTION(x)  CAR(CDR(x))
#define FUNREF_LEXICALS(x)  CDR(CDR(x))

treptr treatom_funref;

bool
trebuiltin_is_compiled_funref (treptr x)
{
	return TREPTR_IS_CONS(x) && CAR(x) == treatom_funref;
}

treptr
trebuiltin_call_compiled (treptr func, treptr x)
{
	ffi_cif cif;
	ffi_type **args;
	treptr *refs;
	void **values;
	treptr rc;
	int i;
	void * fun;
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
		fun = TREATOM_COMPILED_FUN(func);
		ffi_call(&cif, fun, &rc, values);
	} else
        treerror_norecover (treptr_nil, "libffi: cif is not O.K.");

    trealloc_free (args);
    trealloc_free (refs);
    trealloc_free (values);
	return rc;
}

treptr
treeval_compiled_expr (treptr func, treptr args, treptr argdef, bool do_expand)
{
    treptr  expforms;
    treptr  expvals;
	treptr  result;

   	tregc_push (args);
   	trearg_expand (&expforms, &expvals, argdef, args, do_expand);
   	tregc_push (expvals);

    result = TREPTR_IS_ARRAY(func) ?
             trecode_call (func, expvals) :
	         trebuiltin_call_compiled (func, expvals);

	tregc_pop ();
	tregc_pop ();

	return result;
}

treptr
trebuiltin_apply_bytecode_call (treptr func, treptr args, bool do_argeval)
{
    treptr  expforms;
    treptr  expvals;
	treptr  result;
	treptr  i;
    int     num_args;

    tregc_push (func);
    tregc_push (args);

   	trearg_expand (&expforms, &expvals, TREARRAY_RAW(func)[0], args, do_argeval);
   	tregc_push (expvals);

    num_args = trelist_length (expvals);
    DOLIST(i, expvals)
        *--trestack_ptr = CAR(i);

	result = trecode_exec (func);
    trestack_ptr += num_args;

	tregc_pop ();
	tregc_pop ();
	tregc_pop ();

	return result;
}

treptr
trebuiltin_apply_compiled_call (treptr func, treptr args)
{
	return TREPTR_IS_ARRAY(func) ?
		       trebuiltin_apply_bytecode_call (func, args, FALSE) :
	           treeval_compiled_expr (func, args, CAR(TREATOM_VALUE(func)), FALSE);
}

treptr
function_arguments (treptr f)
{
     return TREPTR_IS_ARRAY(f) ?
                TREARRAY_RAW(f)[0] :
                TREATOM_VALUE(f);
}

treptr
trebuiltin_apply_args (treptr list)
{
    treptr i;
    treptr last;

    RETURN_NIL(list); /* No arguments. */

    /* Handle single argument. */
    if (CDR(list) == treptr_nil) {
        list = CAR(list);
        if (TREPTR_IS_ATOM(list) && list != treptr_nil)
            goto error;
		return list;
    }

    /* Handle two or more arguments. */
    DOLIST(i, list) {
        if (CDDR(i) != treptr_nil)
            continue;

        last = CADR(i);
        if (TREPTR_IS_ATOM(last) && last != treptr_nil)
            goto error;

        RPLACD(i, last);
        break;
    }

    return list;

error:
    return treerror (list, "last argument must be a list (waiting for new argument list)");
}

treptr
trebuiltin_apply (treptr list)
{
    treptr  func;
    treptr  f;
    treptr  args;
    treptr  fake;
	treptr  res;
	treptr  a;
	treptr  b;

    if (list == treptr_nil)
		return treerror (list, "arguments expected");

    func = CAR(list);
    args = trebuiltin_apply_args (trelist_copy (CDR(list)));

	if (trebuiltin_is_compiled_funref (func)) {
		tregc_push (args);
        f = FUNREF_FUNCTION(func);
        if (TREPTR_IS_ARRAY(TREATOM_FUN(f)))
            f = TREATOM_FUN(f);
		b = CONS(FUNREF_LEXICALS(func), args);
        a = function_arguments (f);
		res = treeval_compiled_expr (f, b, a, FALSE);
		tregc_pop ();
		return res;
	}

	if (IS_COMPILED_FUN(func)) {
		tregc_push (args);
		res = trebuiltin_apply_compiled_call (func, args);
		tregc_pop ();
		return res;
	}

    fake = CONS(func, args);
    tregc_push (fake);

    if (TREPTR_IS_FUNCTION(func))
        res = treeval_funcall (func, fake, FALSE);
    else if (TREPTR_IS_BUILTIN(func))
        res = treeval_xlat_function (treeval_xlat_builtin, func, fake, FALSE);
    else if (TREPTR_IS_SPECIAL(func))
        res = trespecial (func, fake);
    else
        res = treerror (func, "function expected");

    tregc_pop ();
    TRELIST_FREE_EARLY(fake);

    return res;
}

void
trebuiltin_apply_init ()
{
    treatom_funref = treatom_get ("%FUNREF", TRECONTEXT_PACKAGE());
    EXPAND_UNIVERSE(treatom_funref);
}
