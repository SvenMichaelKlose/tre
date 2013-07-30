/*
 * tré – Copyright (c) 2005–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <sys/mman.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "string2.h"
#include "argument.h"
#include "eval.h"
#include "macro.h"
#include "gc.h"
#include "print.h"
#include "error.h"
#include "io.h"
#include "io_std.h"
#include "thread.h"
#include "special.h"
#include "alien.h"
#include "apply.h"
#include "builtin_arith.h"
#include "builtin_array.h"
#include "builtin_atom.h"
#include "builtin_debug.h"
#include "builtin_error.h"
#include "builtin_fileio.h"
#include "builtin_function.h"
#include "builtin_image.h"
#include "builtin_list.h"
#include "builtin_net.h"
#include "builtin_number.h"
#include "builtin_sequence.h"
#include "builtin_stream.h"
#include "builtin_string.h"
#include "builtin_symbol.h"
#include "builtin_time.h"
#include "main.h"
#include "xxx.h"

treevalfunc_t treeval_xlat_builtin[];

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
    return treerror (list, "Last argument must be a list - please provide a new argument list.");
}

treptr
trebuiltin_apply (treptr list)
{
    if (list == treptr_nil)
        return treerror (list, "Arguments expected.");
    return trefuncall (CAR(list), trebuiltin_apply_args (trelist_copy (CDR(list))));
}

treptr
trebuiltin_funcall (treptr list)
{
    if (list == treptr_nil)
        return treerror (list, "Arguments expected.");
    return trefuncall (CAR(list), CDR(list));
}

treptr
trebuiltin_eval (treptr list)
{
    return treeval (trearg_get (list));
}

treptr
trebuiltin_quit (treptr args)
{
    treptr  arg;
    int      code = 0;

    if (args != treptr_nil) {
        arg = CAR(args);
        if (TREPTR_IS_NUMBER(arg) == FALSE)
	    	return treerror (arg, "Integer expected.");
        code = TRENUMBER_VAL(arg);
    }

    tre_exit (code);

    /*NOTREACHED*/
    return treptr_nil;
}

treptr
trebuiltin_print (treptr expr)
{
    expr = trearg_get (expr);
    treprint (expr);
    return expr;
}

treptr
trebuiltin_load (treptr expr)
{
    struct  tre_stream *stream;
    treptr  pathname = trearg_get (expr);
    char    fname[1024];

	pathname = trearg_typed (1, TRETYPE_STRING, pathname, "LOAD");

    trestring_copy (fname, pathname);

#ifdef TRE_VERBOSE_LOAD
    printf ("(load \"%s\")\n", fname);
#endif

    stream = treiostd_open_file (fname);
    if (stream == NULL) {
        treerror_norecover (treptr_invalid, "Couldn't load file %s.", fname);
		return treptr_nil;
	}

    treiostd_divert (stream);
    tre_main ();
    treiostd_undivert ();

    return treptr_nil;
}

treptr
trebuiltin_gc (treptr no_args)
{
    (void) no_args;
    tregc_force ();
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
	    	treerror (args, "One or two arguments required.");
    } else
        package = treptr_nil;

	name = trearg_typed (1, TRETYPE_STRING, name, "INTERN");
    if (package != treptr_nil)
		package = trearg_typed (1, TRETYPE_STRING, package, "INTERN");

    n = TREPTR_STRINGZ(name);
    if (package != treptr_nil)
        p = treatom_get (TREPTR_STRINGZ(package), treptr_nil);
    else
        p = treptr_nil;

    return treatom_get (n, p);
}

treptr
trebuiltin_malloc (treptr args)
{
    treptr  len;
    void    * ret;

    len = trearg_get (args);
	len = trearg_typed (1, TRETYPE_NUMBER, len, "%MALLOC");

	ret = malloc ((size_t) TRENUMBER_VAL(len));

	return treatom_number_get ((double) (long) ret, TRENUMTYPE_INTEGER);
}

treptr
trebuiltin_malloc_exec (treptr args)
{
    treptr  len;
    void    * ret;

    len = trearg_get (args);
	len = trearg_typed (1, TRETYPE_NUMBER, len, "%MALLOC-EXEC");

	ret = mmap (NULL, (size_t) TRENUMBER_VAL(len),
				PROT_READ | PROT_WRITE | PROT_EXEC,
				MAP_PRIVATE | MAP_ANON,
				-1, 0);

	return treatom_number_get ((double) (long) ret, TRENUMTYPE_INTEGER);
}

treptr
trebuiltin_free (treptr args)
{
    treptr  ptr;

    ptr = trearg_get (args);
	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%FREE");

	free ((void *) (long) TRENUMBER_VAL(ptr));

	return treptr_nil;
}

treptr
trebuiltin_free_exec (treptr args)
{
    treptr  ptr;
    treptr  len;

    trearg_get2 (&ptr, &len, args);
	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%FREE-EXEC");
	len = trearg_typed (1, TRETYPE_NUMBER, len, "%FREE-EXEC");

	munmap ((void *) (long) TRENUMBER_VAL(ptr), (size_t) TRENUMBER_VAL(len));

	return treptr_nil;
}

treptr
trebuiltin_set (treptr args)
{
    treptr ptr;
    treptr val;
	char   c;
	char   * p;

    trearg_get2 (&ptr, &val, args);

	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%%SET");
	val = trearg_typed (2, TRETYPE_NUMBER, val, "%%SET");

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

	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%%GET");

	p = TRENUMBER_CHARPTR(ptr);

	return treatom_number_get ((double) * p, TRENUMTYPE_FLOAT);
}


char *tre_builtin_names[] = {
    "QUIT",
    "LOAD",
    "EVAL", "APPLY",
    "PRINT",
    "GC",
    "DEBUG",
    "INTERN",
	"%MALLOC", "%MALLOC-EXEC", "%FREE", "%FREE-EXEC",
	"%%SET", "%%GET",

	"%ERROR",

	"NUMBER+", "NUMBER-",
	"INTEGER+", "INTEGER-",
	"CHARACTER+", "CHARACTER-",
	"*", "/", "MOD",
    "LOGXOR", "SQRT", "SIN", "COS", "ATAN", "ATAN2", "RANDOM", "EXP", "POW", "ROUND",
    "NUMBER?",
    "==", "<", ">",
    "NUMBER==", "NUMBER<", "NUMBER>",
    "INTEGER==", "INTEGER<", "INTEGER>",
    "CHARACTER==", "CHARACTER<", "CHARACTER>",
	"BIT-OR", "BIT-AND",
	"<<", ">>",
    "CODE-CHAR", "INTEGER", "FLOAT",
    "CHARACTER?",

    "NOT", "EQ", "EQL",
	"ATOM", "SYMBOL?", "FUNCTION?", "BUILTIN?", "MACROP",
    "%TYPE-ID", "%%ID",

    "MAKE-SYMBOL", "MAKE-PACKAGE",
    "SYMBOL-VALUE", "=-SYMBOL-VALUE",
    "SYMBOL-FUNCTION", "=-SYMBOL-FUNCTION",
    "SYMBOL-PACKAGE",

    "FUNCTION-NATIVE",
    "FUNCTION-BYTECODE", "=-FUNCTION-BYTECODE",
    "FUNCTION-SOURCE", "=-FUNCTION-SOURCE",
    "MAKE-FUNCTION",

	"CONS", "CAR", "CDR", "CPR", "RPLACA", "RPLACD", "RPLACP",

    "CONS?",

    "ELT", "%SET-ELT", "LENGTH",

	"STRING?",
    "MAKE-STRING", "STRING==", "STRING-CONCAT", "STRING", "SYMBOL-NAME",
	"LIST-STRING",

    "MAKE-ARRAY", "ARRAY?", "AREF", "=-AREF",

    "MACROEXPAND-1", "MACROEXPAND",

    "%PRINC", "%FORCE-OUTPUT", "%READ-CHAR",
    "%FOPEN", "%FEOF", "%FCLOSE", "%TERMINAL-RAW", "%TERMINAL-NORMAL",

	"END-DEBUG", "INVOKE-DEBUGGER",

    "ALIEN-DLOPEN", "ALIEN-DLCLOSE", "ALIEN-DLSYM",
    "ALIEN-CALL",

    "SYS-IMAGE-CREATE", "SYS-IMAGE-LOAD",

    "NANOTIME",

    "OPEN-SOCKET", "ACCEPT", "RECV", "SEND", "CLOSE-CONNECTION", "CLOSE-SOCKET",

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
    trebuiltin_quit,
    trebuiltin_load,
    trebuiltin_eval,
    trebuiltin_apply,
    trebuiltin_print,
    trebuiltin_gc,
    trebuiltin_debug,
    trebuiltin_intern,
	trebuiltin_malloc,
	trebuiltin_malloc_exec,
	trebuiltin_free,
	trebuiltin_free_exec,
	trebuiltin_set,
	trebuiltin_get,

    treerror_builtin_error,

    trenumber_builtin_plus,
    trenumber_builtin_difference,
    trenumber_builtin_plus,
    trenumber_builtin_difference,
    trenumber_builtin_character_plus,
    trenumber_builtin_character_difference,
    trenumber_builtin_times,
    trenumber_builtin_quotient,
    trenumber_builtin_mod,
    trenumber_builtin_logxor,
    trenumber_builtin_sqrt,
    trenumber_builtin_sin,
    trenumber_builtin_cos,
    trenumber_builtin_atan,
    trenumber_builtin_atan2,
    trenumber_builtin_random,
    trenumber_builtin_exp,
    trenumber_builtin_pow,
    trenumber_builtin_round,
    trenumber_builtin_numberp,
    trenumber_builtin_number_equal,
    trenumber_builtin_lessp,
    trenumber_builtin_greaterp,
    trenumber_builtin_number_equal,
    trenumber_builtin_lessp,
    trenumber_builtin_greaterp,
    trenumber_builtin_number_equal,
    trenumber_builtin_lessp,
    trenumber_builtin_greaterp,
    trenumber_builtin_number_equal,
    trenumber_builtin_lessp,
    trenumber_builtin_greaterp,
    trenumber_builtin_bit_or,
    trenumber_builtin_bit_and,
    trenumber_builtin_bit_shift_left,
    trenumber_builtin_bit_shift_right,
    trenumber_builtin_code_char,
    trenumber_builtin_integer,
    trenumber_builtin_float,
    trenumber_builtin_characterp,

    treatom_builtin_not,
    treatom_builtin_eq,
    treatom_builtin_eql,
    treatom_builtin_atom,
    treatom_builtin_symbolp,
    treatom_builtin_functionp,
    treatom_builtin_builtinp,
    treatom_builtin_macrop,
    treatom_builtin_type_id,
    treatom_builtin_id,

    tresymbol_builtin_make_symbol,
    tresymbol_builtin_make_package,
    tresymbol_builtin_symbol_value,
    tresymbol_builtin_usetf_symbol_value,
    tresymbol_builtin_symbol_function,
    tresymbol_builtin_usetf_symbol_function,
    tresymbol_builtin_symbol_package,

    trefunction_builtin_function_native,
    trefunction_builtin_function_bytecode,
    trefunction_builtin_usetf_function_bytecode,
    trefunction_builtin_function_source,
    trefunction_builtin_set_source,
    trefunction_builtin_make_function,

    trelist_builtin_cons,
    trelist_builtin_car,
    trelist_builtin_cdr,
    trelist_builtin_cpr,
    trelist_builtin_rplaca,
    trelist_builtin_rplacd,
    trelist_builtin_rplacp,
    trelist_builtin_consp,

    tresequence_builtin_elt,
    tresequence_builtin_set_elt,
    tresequence_builtin_length,

    trestring_builtin_stringp,
    trestring_builtin_make,
    trestring_builtin_compare,
    trestring_builtin_concat,
    trestring_builtin_string,
    trestring_builtin_symbol_name,
    trestring_builtin_list_string,

    trearray_builtin_make,
    trearray_builtin_p,
    trearray_builtin_aref,
    trearray_builtin_set_aref,

    tremacro_builtin_macroexpand_1,
    tremacro_builtin_macroexpand,

    trestream_builtin_princ,
    trestream_builtin_force_output,
    trestream_builtin_read_char,
    trestream_builtin_fopen,
    trestream_builtin_feof,
    trestream_builtin_fclose,
    trestream_builtin_terminal_raw,
    trestream_builtin_terminal_normal,

    tredebug_builtin_end_debug,
    tredebug_builtin_invoke_debugger,

    trealien_builtin_dlopen,
    trealien_builtin_dlclose,
    trealien_builtin_dlsym,
    trealien_builtin_call,

    treimage_builtin_create,
    treimage_builtin_load,

    tretime_builtin_nanotime,

    trenet_builtin_open_socket,
    trenet_builtin_accept,
    trenet_builtin_recv,
    trenet_builtin_send,
    trenet_builtin_close_connection,
    trenet_builtin_close_socket,

    NULL
};

treptr
trebuiltin (treptr func, treptr args)
{
    return treeval_xlat_function (treeval_xlat_builtin, func, args, TRUE);
}
