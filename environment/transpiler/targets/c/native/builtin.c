/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <sys/mman.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "string2.h"
#include "gc.h"
#include "error.h"
#include "thread.h"
#include "stream.h"
#include "stream_file.h"
#include "symtab.h"
#include "symbol.h"
#include "alien.h"
#include "funcall.h"
#include "builtin_apply.h"
#include "builtin_arith.h"
#include "builtin_array.h"
#include "builtin_atom.h"
#include "builtin_error.h"
#include "builtin_fs.h"
#include "builtin_function.h"
#include "builtin_image.h"
#include "builtin_list.h"
#include "builtin_memory.h"
#include "builtin_net.h"
#include "builtin_number.h"
#include "builtin_sequence.h"
#include "builtin_stream.h"
#include "builtin_string.h"
#include "builtin_symbol.h"
#include "builtin_terminal.h"
#include "builtin_time.h"
#include "main.h"
#include "xxx.h"

evalfunc_t eval_xlat_builtin[];

treptr
trebuiltin_quit (treptr args)
{
    treptr  arg;
    int     code = 0;

    if (NOT_NIL(args)) {
        arg = CAR(args);
        if (NUMBERP(arg) == FALSE)
	    	return treerror (arg, "Integer expected.");
        code = TRENUMBER_VAL(arg);
    }

    tre_exit (code);

    /*NOTREACHED*/
    return NIL;
}

treptr
trebuiltin_gc (treptr no_args)
{
    (void) no_args;
    tregc ();
    return NIL;
}

char *tre_builtin_names[] = {
    "QUIT",
    "LOAD",
    "EVAL", "APPLY",
    "PRINT",
    "GC",
    "DEBUG",
	"%MALLOC", "%MALLOC-EXEC", "%FREE", "%FREE-EXEC",
	"%%SET", "%%GET",

	"%ERROR", "%STRERROR",

	"NUMBER+", "NUMBER-",
	"INTEGER+", "INTEGER-",
	"CHARACTER+", "CHARACTER-",
	"*", "/", "MOD",
    "LOGXOR", "SQRT", "SIN", "COS", "ATAN", "ATAN2", "RANDOM", "EXP", "POW", "ROUND", "FLOOR",
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
	"ATOM", "SYMBOL?", "FUNCTION?", "BUILTIN?", "MACRO?",
    "%TYPE-ID", "%%ID",

    "MAKE-SYMBOL", "MAKE-PACKAGE",
    "SYMBOL-VALUE", "=-SYMBOL-VALUE",
    "SYMBOL-FUNCTION", "=-SYMBOL-FUNCTION",
    "SYMBOL-PACKAGE",

    "FUNCTION-NATIVE",
    "FUNCTION-BYTECODE", "=-FUNCTION-BYTECODE",
    "FUNCTION-NAME", "FUNCTION-SOURCE", "=-FUNCTION-SOURCE",
    "MAKE-FUNCTION",

	"CONS", "CAR", "CDR", "CPR", "RPLACA", "RPLACD", "RPLACP",

    "CONS?",

    "LAST", "COPY-LIST", "NTHCDR", "NTH", "FILTER", "MAPCAR",

    "ELT", "%SET-ELT", "LENGTH",

	"STRING?",
    "MAKE-STRING", "STRING==", "STRING-CONCAT", "STRING", "SYMBOL-NAME",
	"LIST-STRING",

    "MAKE-ARRAY", "ARRAY?", "AREF", "=-AREF",

    "MACROEXPAND-1", "MACROEXPAND",

    "%PRINC", "%FORCE-OUTPUT", "%READ-CHAR",
    "FILE-EXISTS?", "%FOPEN", "%FEOF", "%FCLOSE", "%DIRECTORY", "%STAT", "READLINK",
    "%TERMINAL-RAW", "%TERMINAL-NORMAL",

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
    return NIL;
}

evalfunc_t eval_xlat_builtin[] = {
    trebuiltin_quit,
    trebuiltin_load,
    trebuiltin_eval,
    trebuiltin_apply,
    trebuiltin_print,
    trebuiltin_gc,
    trebuiltin_debug,
	trebuiltin_malloc,
	trebuiltin_malloc_exec,
	trebuiltin_free,
	trebuiltin_free_exec,
	trebuiltin_set,
	trebuiltin_get,

    treerror_builtin_error,
    treerror_builtin_strerror,

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
    trenumber_builtin_floor,
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

    atom_builtin_not,
    atom_builtin_eq,
    atom_builtin_eql,
    atom_builtin_atom,
    atom_builtin_symbolp,
    atom_builtin_functionp,
    atom_builtin_builtinp,
    atom_builtin_macrop,
    atom_builtin_type_id,
    atom_builtin_id,

    tresymbol_builtin_make_symbol,
    tresymbol_builtin_make_package,
    tresymbol_builtin_symbol_value,
    tresymbol_builtin_usetf_symbol_value,
    tresymbol_builtin_symbol_function,
    tresymbol_builtin_usetf_symbol_function,
    tresymbol_builtin_symbol_package,

    trefunction_builtin_function_native,
    trefunction_builtin_function_bytecode,
    trefunction_builtin_set_bytecode,
    trefunction_builtin_function_name,
    trefunction_builtin_function_source,
    trefunction_builtin_set_source,
    trefunction_builtin_make_function,

    list_builtin_cons,
    list_builtin_car,
    list_builtin_cdr,
    list_builtin_cpr,
    list_builtin_rplaca,
    list_builtin_rplacd,
    list_builtin_rplacp,
    list_builtin_consp,
    list_builtin_last,
    list_builtin_copy_list,
    list_builtin_nthcdr,
    list_builtin_nth,
    list_builtin_filter,
    list_builtin_mapcar,

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
    trestream_builtin_file_exists,
    trestream_builtin_fopen,
    trestream_builtin_feof,
    trestream_builtin_fclose,
    trestream_builtin_directory,
    trestream_builtin_stat,
    trestream_builtin_readlink,

    treterminal_builtin_raw,
    treterminal_builtin_normal,

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

void
trebuiltin_init ()
{
    treptr name;
    treptr fun;
    size_t i;

    for (i = 0; tre_builtin_names[i] != NULL; i++) {
        fun = atom_alloc (TRETYPE_BUILTIN);
        ATOM(fun) = (void*) i;
        name = symbol_alloc (tre_builtin_names[i], NIL);
        tresymbol_set_function(fun, name);
        EXPAND_UNIVERSE(name);
    }
}
