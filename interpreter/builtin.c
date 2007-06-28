/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "sequence.h"
#include "string.h"
#include "eval.h"
#include "error.h"
#include "print.h"
#include "gc.h"
#include "macro.h"
#include "debug.h"
#include "io.h"
#include "io_std.h"
#include "main.h"
#include "thread.h"
#include "stream.h"
#include "argument.h"
#include "special.h"
#include "builtin_arith.h"
#include "builtin_array.h"
#include "builtin_atom.h"
#include "builtin_debug.h"
#include "builtin_fileio.h"
#include "builtin_list.h"
#include "builtin_number.h"
#include "builtin_stream.h"
#include "builtin_string.h"
#include "string.h"
#include "array.h"
#include "alien_dl.h"
#include "xxx.h"
#include "util.h"

#include <stdio.h>
#include <math.h>
#include <string.h>

lispevalfunc_t lispeval_xlat_builtin[];

lispptr
lispbuiltin_identity (lispptr args)
{
    return lisparg_get (args);
}

/*
 * (QUIT)
 *
 * Terminate the interpreter.
 */
lispptr
lispbuiltin_quit (lispptr args)
{
    lispptr  arg;
    int      code = 0;

    if (args != lispptr_nil) {
        arg = CAR(args);
        if (LISPPTR_IS_NUMBER(arg) == FALSE)
	    return lisperror (arg, "integer expected");
        code = LISPNUMBER_VAL(arg);
    }

    printnl ();
    lisp_exit (code);

    /*NOTREACHED*/
    return lispptr_nil;
}

/*
 * (PRINT obj)
 *
 * Print object in LISP notation. Returns the printed object.
 */
lispptr
lispbuiltin_print (lispptr expr)
{
    expr = lisparg_get (expr);
    lispprint (expr);
    return expr;
}

/*
 * (EVAL expression)
 *
 * Evaluates expression and returns its result.
 */
lispptr
lispbuiltin_eval (lispptr list)
{
    return lispeval (lisparg_get (list));
}

/*
 * Convert APPLY arguments into simple list
 *
 * The last element of the list must be a list which is copied and
 * appended to the second last element. The last list is copied because
 * it'd be removed as a part of the temporary argument list.
 */
lispptr
lispbuiltin_apply_args (lispptr list)
{
    lispptr i;

    RETURN_NIL(list); /* No arguments. */

    /* Handle single argument. */
    if (CDR(list) == lispptr_nil) {
	RETURN_NIL(CAR(list));
        if (LISPPTR_IS_EXPR(CAR(list)) == FALSE)
            goto error;
        return lisplist_copy (CAR(list));
    }

    /* Handle two or more arguments. */
    DOLIST(i, list) {
        if (CDDR(i) != lispptr_nil)
            continue;
        if (CADR(i) == lispptr_nil)
	    break;
        if (LISPPTR_IS_EXPR(CADR(i)) == FALSE)
            goto error;

        RPLACD(i, lisplist_copy (CADR(i)));
        break;
    }

    return list;

error:
    return lisperror (list, "last argument must be a list "
                            "(waiting for new argument list)");
}

/*
 * (APPLY function args... )
 *
 * Call function with argument list.
 */
lispptr
lispbuiltin_apply (lispptr list)
{
    lispptr  func;
    lispptr  args;
    lispptr  fake;
    lispptr  efunc;
    lispptr  res;

    if (list == lispptr_nil)
	return lisperror (list, "arguments expected");

    func = CAR(list);
    args = lispbuiltin_apply_args (lisplist_copy (CDR(list)));

    fake = CONS(func, args);
    lispgc_push (fake);

    efunc = lispeval (func);
    RPLACA(fake, efunc);

    /* Avoid re-evaluation of arguments. */
    if (LISPPTR_IS_FUNCTION(efunc))
        res = lispeval_funcall (efunc, fake, FALSE);
    else if (LISPPTR_IS_BUILTIN(efunc))
        res = lispeval_xlat_function (lispeval_xlat_builtin, efunc, fake, FALSE);
    else if (LISPPTR_IS_SPECIAL(efunc))
        res = lispspecial (efunc, fake);
    else
        res = lisperror (efunc, "function expected");

    lispgc_pop ();
    LISPLIST_FREE_EARLY(fake);

    return res;
}

lispptr
lispbuiltin_macrocall (lispptr list)
{
    lispptr macro;
    lispptr args;
    lispptr fake;
    lispptr res;

    lisparg_get2 (&macro, &args, list);

    if (LISPPTR_IS_MACRO(macro) == FALSE) {
	lisperror_norecover (list, "macro expected");
	return lispptr_nil;
    }

    fake = CONS(macro, args);
    lispgc_push (fake);

    lispthread_push_call (CDR(LISPATOM_VALUE(macro)));
    res = lispeval_funcall (macro, fake, FALSE);
    lispthread_pop_call ();

    lispgc_pop ();
    LISPLIST_FREE_EARLY(fake);

    return res;
}

lispptr
lispbuiltin_load (lispptr expr)
{
    struct lisp_stream *stream;
    lispptr  arg = lisparg_get (expr);
    char     fname[1024];

    if (LISPPTR_IS_STRING(arg) == FALSE)
	return lisperror (arg, "string expected");

    lispstring_copy (fname, arg);

#ifdef LISP_VERBOSE_LOAD
    printf ("(load \"%s\")\n", fname);
#endif

    stream = lispiostd_open_file (fname);
    if (stream == NULL)
        return lisperror (lispptr_invalid, "couldn't load file %s", fname);

    lispiostd_divert (stream);
    lisp_main ();
    lispiostd_undivert ();

    return lispptr_nil;
}

/*
 * Force garbage collection.
 */
lispptr
lispbuiltin_gc (lispptr no_args)
{
    (void) no_args;

    lispgc_force_user ();

    return lispptr_nil;
}

lispptr
lispbuiltin_intern (lispptr args)
{
    lispptr  name;
    lispptr  package;
    lispptr  p;
    char     *n;

    name = CAR(args);
    if (LISPPTR_IS_EXPR(CDR(args))) {
        package = CADR(args);
        if (CDDR(args) != lispptr_nil)
	    lisperror (args, "INTERN: one or two arguments required");
    } else
        package = lispptr_nil;

    if (LISPPTR_IS_STRING(name) == FALSE)
	lisperror (name, "first argument (the symbol name) must be a string");
    if (!package == lispptr_nil && LISPPTR_IS_STRING(package) == FALSE)
	lisperror (name, "second argument (the package name) must be a string");

    n = &LISPATOM_STRING(name)->str;
    if (package != lispptr_nil)
        p = lispatom_get (&LISPATOM_STRING(package)->str, lispptr_nil);
    else
        p = lispptr_nil;

    return lispatom_get (n, p);
}

char *lisp_builtin_names[] = {
    "IDENTITY",
    "QUIT", "ERROR", "+", "-", "*", "/", "MOD",
    "LOGXOR",
    "EQ", "EQL", "CONS", "LIST",
    "PRINT",

    "CAR", "CDR", "RPLACA", "RPLACD",

    "EVAL", "APPLY", "%MACROCALL",

    "MAKE-SYMBOL", "ATOM", "SYMBOL-VALUE", "%ATOM-VALUE", "SYMBOL-FUNCTION",
    "%MKFUNCTIONATOM", "CONSP", "NUMBERP", "FUNCTIONP",
    "BOUNDP", "FBOUNDP",
    "MACROP", "STRINGP",
    "=", "<", ">",

    "ELT", "%SET-ELT", "LENGTH",

    "CODE-CHAR", "INTEGER",

    "CHARACTERP",

    "MAKE-STRING", "STRING-CONCAT", "STRING", "SYMBOL-NAME",

    "MAKE-ARRAY", "ARRAYP", "AREF", "%SET-AREF",

    "MACROEXPAND-1", "MACROEXPAND",

    "LOAD",

    "%PRINC", "%FORCE-OUTPUT", "%READ-CHAR",
    "%FOPEN", "%FEOF",

    "GC", "END-DEBUG", "INVOKE-DEBUGGER",

    "%ATOM-LIST",

    "ALIEN-DLOPEN", "ALIEN-DLCLOSE", "ALIEN-DLSYM",
    "ALIEN-CALL0", "ALIEN-CALL1", "ALIEN-CALL2", "ALIEN-CALL3", "ALIEN-CALL4",

    "DEBUG",

    "INTERN",

    NULL
};

lispptr
lispbuiltin_debug (lispptr no_args)
{
    (void) no_args;

    printf ("(DEBUG) called!");
    return lispptr_nil;
}

lispevalfunc_t lispeval_xlat_builtin[] = {
    lispbuiltin_identity,
    lispbuiltin_quit,
    lisperror_builtin_error,

    lispnumber_builtin_plus,
    lispnumber_builtin_difference,
    lispnumber_builtin_times,
    lispnumber_builtin_quotient,
    lispnumber_builtin_mod,
    lispnumber_builtin_logxor,

    lispatom_builtin_eq,
    lispatom_builtin_eql,

    lisplist_builtin_cons,
    lisplist_builtin_list,

    lispbuiltin_print,

    lisplist_builtin_car,
    lisplist_builtin_cdr,
    lisplist_builtin_rplaca,
    lisplist_builtin_rplacd,

    lispbuiltin_eval,
    lispbuiltin_apply,
    lispbuiltin_macrocall,

    lispatom_builtin_make_symbol,

    lispatom_builtin_atom,
    lispatom_builtin_symbol_value,
    lispatom_builtin_atom_value,
    lispatom_builtin_symbol_function,
    lispatom_builtin_mkfunctionatom,
    lisplist_builtin_consp,
    lispnumber_builtin_numberp,
    lispatom_builtin_functionp,
    lispatom_builtin_boundp,
    lispatom_builtin_fboundp,
    lispatom_builtin_macrop,
    lispstring_builtin_stringp,

    lispnumber_builtin_number_equal,
    lispnumber_builtin_lessp,
    lispnumber_builtin_greaterp,

    lispsequence_builtin_elt,
    lispsequence_builtin_set_elt,
    lispsequence_builtin_length,

    /* type conversion */
    lispnumber_builtin_code_char,
    lispnumber_builtin_integer,

    /* type checking */
    lispnumber_builtin_characterp,

    /* string functions */
    lispstring_builtin_make,
    lispstring_builtin_concat,
    lispstring_builtin_string,
    lispstring_builtin_symbol_name,

    /* array functions */
    lisparray_builtin_make,
    lisparray_builtin_p,
    lisparray_builtin_aref,
    lisparray_builtin_set_aref,

    lispmacro_builtin_macroexpand_1,
    lispmacro_builtin_macroexpand,

    lispbuiltin_load,

    lispstream_builtin_princ,
    lispstream_builtin_force_output,
    lispstream_builtin_read_char,

    lispstream_builtin_fopen,
    lispstream_builtin_feof,

    lispbuiltin_gc,

    lispdebug_builtin_end_debug,
    lispdebug_builtin_invoke_debugger,

    lispatom_builtin_atom_list,

    lispalien_builtin_dlopen,
    lispalien_builtin_dlclose,
    lispalien_builtin_dlsym,
    lispalien_builtin_dlcall0,
    lispalien_builtin_dlcall1,
    lispalien_builtin_dlcall2,
    lispalien_builtin_dlcall3,
    lispalien_builtin_dlcall4,

    lispbuiltin_debug,
    lispbuiltin_intern,
    NULL
};

/*
 * Call built-in function
 */
lispptr
lispbuiltin (lispptr func, lispptr expr)
{
    return lispeval_xlat_function (lispeval_xlat_builtin, func, expr, TRUE);
}
