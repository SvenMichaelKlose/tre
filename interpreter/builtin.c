/*
 * tré – Copyright (c) 2005–2012 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "alloc.h"
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
#include "builtin_apply.h"
#include "builtin_arith.h"
#include "builtin_array.h"
#include "builtin_atom.h"
#include "builtin_debug.h"
#include "builtin_error.h"
#include "builtin_fileio.h"
#include "builtin_image.h"
#include "builtin_list.h"
#include "builtin_net.h"
#include "builtin_number.h"
#include "builtin_sequence.h"
#include "builtin_stream.h"
#include "builtin_string.h"
#include "main.h"

#include <sys/mman.h>

treevalfunc_t treeval_xlat_builtin[];

/*tredoc
  (cmd name "QUIT" type "bt"
    (description
	  "Terminate the interpreter."))
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

/*tredoc
  (cmd name "PRINT"
	(description
 	  "Print object in TRE notation. Returns the printed object.")
	(arg name "obj"))
 */
treptr
trebuiltin_print (treptr expr)
{
    expr = trearg_get (expr);
    treprint (expr);
    return expr;
}

/*tredoc
  (cmd name "EVAL" type "bt"
 	(description
	  "Evaluates object.")
    (arg name "obj")
    (returns
	  "Result of evaluation."))
 */
treptr
trebuiltin_eval (treptr list)
{
    return treeval (trearg_get (list));
}

/*tredoc
   (cmd name "%MACROCALL" type "bt"
	 (description
	   "Executes a macro with arguments.")
	 (args
	   (arg name "macro")
	   (arg name "arguments" type "CONS")))
  */
treptr
trebuiltin_macrocall (treptr list)
{
    treptr macro;
    treptr args;
    treptr fake;
    treptr res;

    trearg_get2 (&macro, &args, list);

	macro = trearg_typed (1, TRETYPE_MACRO, macro, "MACROCALL");

    fake = CONS(macro, args);
    tregc_push (fake);

    trethread_push_call (CDR(TREATOM_VALUE(macro)));
    res = treeval_funcall (macro, fake, FALSE);
    trethread_pop_call ();

    tregc_pop ();
    TRELIST_FREE_EARLY(fake);

    return res;
}

/*tredoc
  (cmd name "LOAD" type "bt"
	(description
	  "Loads and evaluates a file."_)
    (arg name "file-path"))
  */
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
        treerror_norecover (treptr_invalid, "couldn't load file %s", fname);
		return treptr_nil;
	}

    treiostd_divert (stream);
    tre_main ();
    treiostd_undivert ();

    return treptr_nil;
}

/*tredoc
  (cmd name "GC" type "bt"
	(description
	  "Force garbage collection."))
 */
treptr
trebuiltin_gc (treptr no_args)
{
    (void) no_args;
    tregc_force_user ();
    return treptr_nil;
}

/*tredoc
  (cmd name "INTERN" type "bt"
	(description
	  "Create a symbol in a package.")
	(args
	  (arg name "symbol-name" type "string")
	  (optional
		(arg name "package-name" type "string")))
	(see-also "MAKE-SYMBOL"))
  */
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

	name = trearg_typed (1, TRETYPE_STRING, name, "INTERN");
    if (package != treptr_nil)
		package = trearg_typed (1, TRETYPE_STRING, package, "INTERN");

    n = TRESTRING_DATA(TREATOM_STRING(name));
    if (package != treptr_nil)
        p = treatom_get (TRESTRING_DATA(TREATOM_STRING(package)), treptr_nil);
    else
        p = treptr_nil;

    return treatom_get (n, p);
}

/*tredoc
  (cmd name "%MALLOC" type "bt"
    (description
	  "Allocates a block of memory.")
	(arg name "num-bytes" type "INTEGER")
	(returns type "INTEGER" nil "t"
	  "Address of allocated memory block or NIL.")
    (see-also
	  "%MALLOC-EXEC"
	  "%FREE"))
  */
treptr
trebuiltin_malloc (treptr args)
{
    treptr  len;
    void    * ret;

    len = trearg_get (args);
	len = trearg_typed (1, TRETYPE_NUMBER, len, "%MALLOC");

	ret = trealloc ((size_t) TRENUMBER_VAL(len));

	return treatom_number_get ((double) (long) ret, TRENUMTYPE_INTEGER);
}

/*tredoc
  (cmd name "%MALLOC-EXEC" type "bt"
    (description
	  "Allocates a block of executable memory.")
	(arg name "num-bytes" type "INTEGER")
	(returns type "INTEGER" nil "t"
	  "Address of allocated memory block or NIL."))
  */
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

/*tredoc
  (cmd name "%FREE" type "bt"
    (description
	  "Deallocates a block of memory.")
	(arg name "address" type "INTEGER"
	  "Address of allocated memory block.")
	(returns nil))
  */
treptr
trebuiltin_free (treptr args)
{
    treptr  ptr;

    ptr = trearg_get (args);
	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%FREE");

	trealloc_free ((void *) (long) TRENUMBER_VAL(ptr));

	return treptr_nil;
}

/*tredoc
  (cmd name "%FREE-EXEC" type "bt"
    (description
	  "Deallocates a block of executable memory.")
	(arg name "address" type "INTEGER"
	  "Address of allocated memory block.")
	(returns nil))
  */
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

/*tredoc
  (cmd name "%%SET" type "bt"
    (description
	  "Sets byte in memory.")
	(args
	  (arg name "address" type "integer")
	  (arg name "byte" type "character"))
	(returns nil))
  */
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

/*tredoc
  (cmd name "%%GET" type "bt"
    (description
	  "Reads byte from memory.")
	(arg name "address" type "integer")
	(returns type "character"
	  "Value of byte at address."))
  */
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
    "EVAL", "APPLY", "%MACROCALL",
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
    "LOGXOR", "NUMBER?",
    "==", "<", ">",
    "NUMBER==", "NUMBER<", "NUMBER>",
    "INTEGER==", "INTEGER<", "INTEGER>",
    "CHARACTER==", "CHARACTER<", "CHARACTER>",
	"BIT-OR", "BIT-AND",
	"<<", ">>",
    "CODE-CHAR", "INTEGER",
    "CHARACTER?",

    "NOT", "EQ", "EQL",
    "MAKE-SYMBOL", "MAKE-PACKAGE",
	"ATOM", "%TYPE-ID", "%%ID", "%MAKE-PTR",
    "SYMBOL-VALUE", "%SETQ-ATOM-VALUE", "SYMBOL-FUNCTION", "%%U=-SYMBOL-FUNCTION", "SYMBOL-PACKAGE", "SYMBOL-COMPILED-FUNCTION",
	"FUNCTION?", "BUILTIN?", "MACROP",
    "%ATOM-LIST",

	"CONS", "LIST",
    "CAR", "CDR", "RPLACA", "RPLACD",

    "CONS?",

#ifdef TRE_BUILTIN_ASSOC
	"ASSOC",
#endif

#ifdef TRE_BUILTIN_MEMBER
	"MEMBER",
#endif

    "ELT", "%SET-ELT", "LENGTH",

	"STRING?",
    "MAKE-STRING", "STRING==", "STRING-CONCAT", "STRING", "SYMBOL-NAME",
	"LIST-STRING",

    "MAKE-ARRAY", "ARRAY?", "AREF", "%%U=-AREF",

    "MACROEXPAND-1", "MACROEXPAND",

    "%PRINC", "%FORCE-OUTPUT", "%READ-CHAR",
    "%FOPEN", "%FEOF", "%FCLOSE", "%TERMINAL-RAW", "%TERMINAL-NORMAL",

	"END-DEBUG", "INVOKE-DEBUGGER",

    "ALIEN-DLOPEN", "ALIEN-DLCLOSE", "ALIEN-DLSYM",
    "ALIEN-CALL",

    "SYS-IMAGE-CREATE", "SYS-IMAGE-LOAD",

    "OPEN-SOCKET", "ACCEPT", "RECV", "SEND", "CLOSE-CONNECTION", "CLOSE-SOCKET",

    NULL
};

/*tredoc
  (cmd name "DEBUG" type "bt"
	(description
	  "Prints a message. Used as a breakpoint when debugging "
	  "the interpreter.")
	(returns nil))
  */
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
    trebuiltin_macrocall,
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
    trenumber_builtin_characterp,

    treatom_builtin_not,
    treatom_builtin_eq,
    treatom_builtin_eql,
    treatom_builtin_make_symbol,
    treatom_builtin_make_package,
    treatom_builtin_atom,
    treatom_builtin_type_id,
    treatom_builtin_id,
    treatom_builtin_make_ptr,
    treatom_builtin_symbol_value,
    treatom_builtin_setq_atom_value,
    treatom_builtin_symbol_function,
    treatom_builtin_usetf_symbol_function,
    treatom_builtin_symbol_package,
    treatom_builtin_symbol_compiled_function,
    treatom_builtin_functionp,
    treatom_builtin_builtinp,
    treatom_builtin_macrop,
    treatom_builtin_atom_list,

    trelist_builtin_cons,
    trelist_builtin_list,
    trelist_builtin_car,
    trelist_builtin_cdr,
    trelist_builtin_rplaca,
    trelist_builtin_rplacd,
    trelist_builtin_consp,
#ifdef TRE_BUILTIN_ASSOC
    trelist_builtin_assoc,
#endif
#ifdef TRE_BUILTIN_MEMBER
    trelist_builtin_member,
#endif

    tresequence_builtin_elt,
    tresequence_builtin_set_elt,
    tresequence_builtin_length,

    /* string functions */
    trestring_builtin_stringp,
    trestring_builtin_make,
    trestring_builtin_compare,
    trestring_builtin_concat,
    trestring_builtin_string,
    trestring_builtin_symbol_name,
    trestring_builtin_list_string,

    /* array functions */
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

    trenet_builtin_open_socket,
    trenet_builtin_accept,
    trenet_builtin_recv,
    trenet_builtin_send,
    trenet_builtin_close_connection,
    trenet_builtin_close_socket,

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
