/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Built-in functions.
 */

#include "config.h"
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
#include "builtin_image.h"
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

treevalfunc_t treeval_xlat_builtin[];

treptr
trebuiltin_identity (treptr args)
{
    return trearg_get (args);
}

/*
 * (QUIT)
 *
 * Terminate the interpreter.
 */
treptr
trebuiltin_quit (treptr args)
{
    treptr  arg;
    int      code = 0;

    if (args != treptr_nil) {
        arg = CAR(args);
        if (TREPTR_IS_NUMBER(arg) == FALSE)
	    	return treerror (arg, "integer expected");
        code = TRENUMBER_VAL(arg);
    }

    tre_exit (code);

    /*NOTREACHED*/
    return treptr_nil;
}

/*
 * (PRINT obj)
 *
 * Print object in TRE notation. Returns the printed object.
 */
treptr
trebuiltin_print (treptr expr)
{
    expr = trearg_get (expr);
    treprint (expr);
    return expr;
}

/*
 * (EVAL expression)
 *
 * Evaluates expression and returns its result.
 */
treptr
trebuiltin_eval (treptr list)
{
    return treeval (trearg_get (list));
}

/*
 * Convert APPLY arguments into simple list
 *
 * The last element of the list must be a list which is copied and
 * appended to the second last element. The last list is copied because
 * it'd be removed as a part of the temporary argument list.
 */
treptr
trebuiltin_apply_args (treptr list)
{
    treptr i;

    RETURN_NIL(list); /* No arguments. */

    /* Handle single argument. */
    if (CDR(list) == treptr_nil) {
		RETURN_NIL(CAR(list));
        if (TREPTR_IS_ATOM(CAR(list)))
            goto error;
        return trelist_copy (CAR(list));
    }

    /* Handle two or more arguments. */
    DOLIST(i, list) {
        if (CDDR(i) != treptr_nil)
            continue;
        if (CADR(i) == treptr_nil)
	    	break;
        if (TREPTR_IS_ATOM(CADR(i)))
            goto error;

        RPLACD(i, trelist_copy (CADR(i)));
        break;
    }

    return list;

error:
    return treerror (list, "last argument must be a list "
                            "(waiting for new argument list)");
}

/*
 * (APPLY function args... )
 *
 * Call function with argument list.
 */
treptr
trebuiltin_apply (treptr list)
{
    treptr  func;
    treptr  args;
    treptr  fake;
    treptr  efunc;
    treptr  res;

    if (list == treptr_nil)
		return treerror (list, "arguments expected");

    func = CAR(list);
    args = trebuiltin_apply_args (trelist_copy (CDR(list)));

    fake = CONS(func, args);
    tregc_push (fake);

    efunc = treeval (func);
    RPLACA(fake, efunc);

    /* Avoid re-evaluation of arguments. */
    if (TREPTR_IS_FUNCTION(efunc))
        res = treeval_funcall (efunc, fake, FALSE);
    else if (TREPTR_IS_BUILTIN(efunc))
        res = treeval_xlat_function (treeval_xlat_builtin, efunc, fake, FALSE);
    else if (TREPTR_IS_SPECIAL(efunc))
        res = trespecial (efunc, fake);
    else
        res = treerror (efunc, "function expected");

    tregc_pop ();
    TRELIST_FREE_EARLY(fake);

    return res;
}

treptr
trebuiltin_macrocall (treptr list)
{
    treptr macro;
    treptr args;
    treptr fake;
    treptr res;

    trearg_get2 (&macro, &args, list);

	macro = trearg_macro (1, "macro to call", macro);

    fake = CONS(macro, args);
    tregc_push (fake);

    trethread_push_call (CDR(TREATOM_VALUE(macro)));
    res = treeval_funcall (macro, fake, FALSE);
    trethread_pop_call ();

    tregc_pop ();
    TRELIST_FREE_EARLY(fake);

    return res;
}

treptr
trebuiltin_load (treptr expr)
{
    struct  tre_stream *stream;
    treptr  pathname = trearg_get (expr);
    char    fname[1024];

	pathname = trearg_string (1, "pathname", pathname);

    trestring_copy (fname, pathname);

#ifdef TRE_VERBOSE_LOAD
    printf ("(load \"%s\")\n", fname);
#endif

    stream = treiostd_open_file (fname);
    if (stream == NULL)
        return treerror (treptr_invalid, "couldn't load file %s", fname);

    treiostd_divert (stream);
    tre_main ();
    treiostd_undivert ();

    return treptr_nil;
}

/*
 * Force garbage collection.
 */
treptr
trebuiltin_gc (treptr no_args)
{
    (void) no_args;
    tregc_force_user ();
    return treptr_nil;
}

treptr
trebuiltin_intern (treptr args)
{
    treptr  name;
    treptr  package;
    treptr  p;
    char     *n;

    name = CAR(args);
    if (TREPTR_IS_CONS(CDR(args))) {
        package = CADR(args);
        if (CDDR(args) != treptr_nil)
	    	treerror (args, "INTERN: one or two arguments required");
    } else
        package = treptr_nil;

	name = trearg_string (1, "symbol name", name);
    if (package != treptr_nil)
		package = trearg_string (1, "package name", package);

    n = &TREATOM_STRING(name)->str;
    if (package != treptr_nil)
        p = treatom_get (&TREATOM_STRING(package)->str, treptr_nil);
    else
        p = treptr_nil;

    return treatom_get (n, p);
}

treptr
trebuiltin_set (treptr args)
{
    treptr ptr;
    treptr val;
	char   c;
	char   * p;

    trearg_get2 (&ptr, &val, args);

	ptr = trearg_number (1, "address", ptr);
	val = trearg_number (2, "byte", ptr);

	c = (char) TRENUMBER_VAL(val);
	p = TRENUMBER_CHARPTR(ptr);
	* p = c;

    return val;
}

treptr
trebuiltin_get (treptr args)
{
    treptr ptr = trearg_get (args);
	char   * p;

	ptr = trearg_number (1, "address", ptr);

	p = TRENUMBER_CHARPTR(ptr);

	return treatom_number_get ((double) * p, TRENUMTYPE_FLOAT);
}


char *tre_builtin_names[] = {
    "IDENTITY",
    "QUIT", "%ERROR", "+", "-", "*", "/", "MOD",
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
    "%FOPEN", "%FEOF", "%TERMINAL-RAW", "%TERMINAL-NORMAL",

    "GC", "END-DEBUG", "INVOKE-DEBUGGER",

    "%ATOM-LIST",

    "ALIEN-DLOPEN", "ALIEN-DLCLOSE", "ALIEN-DLSYM",
    "ALIEN-CALL",

    "DEBUG",

    "INTERN",

    "SYS-IMAGE-CREATE", "SYS-IMAGE-LOAD",

	"%%SET", "%%GET",

    NULL
};

treptr
trebuiltin_debug (treptr no_args)
{
    (void) no_args;

    printf ("(DEBUG) called!");
    return treptr_nil;
}

treevalfunc_t treeval_xlat_builtin[] = {
    trebuiltin_identity,
    trebuiltin_quit,
    treerror_builtin_error,

    trenumber_builtin_plus,
    trenumber_builtin_difference,
    trenumber_builtin_times,
    trenumber_builtin_quotient,
    trenumber_builtin_mod,
    trenumber_builtin_logxor,

    treatom_builtin_eq,
    treatom_builtin_eql,

    trelist_builtin_cons,
    trelist_builtin_list,

    trebuiltin_print,

    trelist_builtin_car,
    trelist_builtin_cdr,
    trelist_builtin_rplaca,
    trelist_builtin_rplacd,

    trebuiltin_eval,
    trebuiltin_apply,
    trebuiltin_macrocall,

    treatom_builtin_make_symbol,

    treatom_builtin_atom,
    treatom_builtin_symbol_value,
    treatom_builtin_atom_value,
    treatom_builtin_symbol_function,
    treatom_builtin_mkfunctionatom,
    trelist_builtin_consp,
    trenumber_builtin_numberp,
    treatom_builtin_functionp,
    treatom_builtin_boundp,
    treatom_builtin_fboundp,
    treatom_builtin_macrop,
    trestring_builtin_stringp,

    trenumber_builtin_number_equal,
    trenumber_builtin_lessp,
    trenumber_builtin_greaterp,

    tresequence_builtin_elt,
    tresequence_builtin_set_elt,
    tresequence_builtin_length,

    /* type conversion */
    trenumber_builtin_code_char,
    trenumber_builtin_integer,

    /* type checking */
    trenumber_builtin_characterp,

    /* string functions */
    trestring_builtin_make,
    trestring_builtin_concat,
    trestring_builtin_string,
    trestring_builtin_symbol_name,

    /* array functions */
    trearray_builtin_make,
    trearray_builtin_p,
    trearray_builtin_aref,
    trearray_builtin_set_aref,

    tremacro_builtin_macroexpand_1,
    tremacro_builtin_macroexpand,

    trebuiltin_load,

    trestream_builtin_princ,
    trestream_builtin_force_output,
    trestream_builtin_read_char,

    trestream_builtin_fopen,
    trestream_builtin_feof,
    trestream_builtin_terminal_raw,
    trestream_builtin_terminal_normal,

    trebuiltin_gc,

    tredebug_builtin_end_debug,
    tredebug_builtin_invoke_debugger,

    treatom_builtin_atom_list,

    trealien_builtin_dlopen,
    trealien_builtin_dlclose,
    trealien_builtin_dlsym,
    trealien_builtin_call,

    trebuiltin_debug,
    trebuiltin_intern,

    treimage_builtin_create,
    treimage_builtin_load,

	trebuiltin_set,
	trebuiltin_get,

    NULL
};

/*
 * Call built-in function
 */
treptr
trebuiltin (treptr func, treptr expr)
{
    return treeval_xlat_function (treeval_xlat_builtin, func, expr, TRUE);
}
