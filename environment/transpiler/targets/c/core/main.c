/*
 * tré – Copyright (c) 2005–2009,2011–2014,2016 Sven Michael Klose <pixel@copei.de>
 */

#include <setjmp.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <locale.h>
#include <unistd.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "stream.h"
#include "stream_file.h"
#include "stream_string.h"
#include "gc.h"
#include "builtin.h"
#include "thread.h"
#include "error.h"
#include "alloc.h"
#include "symtab.h"
#include "string2.h"
#include "image.h"
#include "util.h"
#include "builtin_arith.h"
#include "builtin_list.h"
#include "builtin_stream.h"
#include "builtin_terminal.h"
#include "bytecode.h"
#include "function.h"
#include "exception.h"
#include "backtrace.h"
#include "symbol.h"
#include "linenoise.h"

#ifdef TRE_HAVE_COMPILED_ENV
treptr tre_cInit (void);
#endif

char * tremain_self = NULL;   /* Path to running executable. */
char * tremain_userimage = NULL;
char * tremain_bootimage = NULL;
char * tremain_launchfile = NULL;
char * tremain_init_expr = NULL;

treptr tremain_history;
treptr tremain_history_2;
treptr tremain_history_3;

bool tremain_noimage = FALSE;

jmp_buf jmp_main;
treptr tre_restart_fun;

int tre_is_initialized;

void
tre_exit (int code)
{
    exit (code);
}

bool tre_interrupt_debugger;

void
tre_signal (int signum)
{
	switch (signum) {
	case SIGINT:
#ifdef TRE_EXIT_ON_SIGINT
		exit (-1);
#else
		if (! tre_interrupt_debugger)
			break;
		printf ("*USER-BREAK*");
		fflush (stdout);
		tredebug_mode = TREDEBUGM_STEP;
        tredebug ();
#endif
		break;
	}
}

void
tre_restart (treptr fun)
{
    tre_restart_fun = fun;
    treiostd_undivert_all ();
    longjmp (jmp_main, -1);
}

treptr
tremain_expand (treptr expr)
{
	treptr old;

    do {
		old = expr;

		tregc_push (expr);
		expr = tredot_expand (expr);

    	expr = tremacro_builtin_macroexpand (CONS(expr, NIL));

		tregc_push (expr);
		expr = trequasiquote_expand (expr);

		tregc_pop ();
		tregc_pop ();
    } while (!list_equal (expr, old));

    return expr;
}

void
tremain_update_history (treptr x)
{
	SYMBOL_VALUE(tremain_history_3) = SYMBOL_VALUE(tremain_history_2);
	SYMBOL_VALUE(tremain_history_2) = SYMBOL_VALUE(tremain_history);
	SYMBOL_VALUE(tremain_history) = x;
}

treptr
tremain_line (trestream * stream)
{
    treptr  expr;

    expr = treread (stream);
    if (expr == treptr_invalid)
        return expr;

    tremain_update_history (expr);
    expr = eval (tremain_expand (expr));

    return expr;
}

void
tremain_prompt ()
{
    (void) treterminal_builtin_normal (NIL);
    printf ("* ");
    tre_interrupt_debugger = FALSE;
    treio_flush (treio_console);
}

void
tremain (void)
{
    treptr       x = treptr_invalid;
    char *       p = getenv ("HOME");
    char *       line;
    char *       history_path = malloc (4096);
    trestream *  s;

    strcpy (history_path, p);
    strcpy (&history_path[strlen (p)], "/.tre-history.lisp");
    linenoiseHistorySetMaxLen (TRE_HISTORY_SIZE);
    linenoiseHistoryLoad (history_path);
    linenoiseSetMultiLine (1);

    while (1) {
        if (!is_standard_stream (treio_reader)) {
            if (tremain_line (treio_reader) == treptr_invalid)
                break;
            continue;
        }

        line = linenoise ("* ");
        if (!line)
            break;

        linenoiseHistoryAdd (line);
        linenoiseHistorySave (history_path);

        s = trestream_string_make (line);
        treiostd_divert (s);
        while (!treio_eof (s)) {
            x = tremain_line (treio_reader);
            if (x != treptr_invalid)
                treprint (x);
        }
        treiostd_undivert ();

        if (x == treptr_invalid)
            break;
    }

    free (history_path);
}

treptr * trestack;
treptr * trestack_top;
treptr * trestack_ptr;

treptr * trestack_secondary;
treptr * trestack_top_secondary;
treptr * trestack_ptr_secondary;

void
tremain_init_image_path (void)
{
    char * p = getenv ("HOME");

    tremain_bootimage = malloc (4096);
    strcpy (tremain_bootimage, p);
    strcpy (&tremain_bootimage[strlen (p)], "/.tre.image");
    if (access (tremain_bootimage, F_OK) == -1) {
        free (tremain_bootimage);
        tremain_bootimage = TRE_DEFAULT_IMAGE;
    }

/*
	MAKE_SYMBOL("*BOOT-IMAGE*", trestring_get (tremain_bootimage));
*/
}

/* Initialize everything. */
void
tremain_init (void)
{
    tre_is_initialized = FALSE;
    tre_interrupt_debugger = FALSE;

	trestack = malloc (sizeof (treptr) * TRESTACK_SIZE);
	trestack_top = trestack_ptr = &trestack[TRESTACK_SIZE];
	trestack_secondary = malloc (sizeof (treptr) * TRESTACK_SIZE_SECONDARY);
	trestack_top_secondary = trestack_ptr_secondary = &trestack[TRESTACK_SIZE_SECONDARY];

    trestream_init ();
    tredebug_init ();
    trethread_make ();
    tregc_init ();
    trecons_init ();
    symtab_init ();
    atom_init ();
    tresymbol_init ();
    trebuiltin_init ();
    trebuiltin_arith_init ();
    trespecial_init ();
    trenumber_init ();
    treread_init ();
    trearg_init ();
    trebacktrace_init ();
    eval_init ();
    tremacro_init ();
    trequasiquote_init ();
    tredot_init ();
    treimage_init ();
    treexception_init ();

    MAKE_SYMBOL("*KERNEL-IDENT*",     trestring_get (TRE_KERNEL_IDENT));
    MAKE_SYMBOL("*CPU-TYPE*",         trestring_get (TRE_CPU_TYPE));
    MAKE_SYMBOL("*OS-RELEASE*",       trestring_get (TRE_OS_RELEASE));
    MAKE_SYMBOL("*OS-VERSION*",       trestring_get (TRE_OS_VERSION));
    MAKE_SYMBOL("*ENVIRONMENT-PATH*", trestring_get (TRE_ENVIRONMENT));
	MAKE_SYMBOL("*LIBC-PATH*",        trestring_get (LIBC_PATH));
	MAKE_SYMBOL("*ENDIANESS*",        symbol_alloc (TRE_ENDIANESS_STRING, NIL));
	MAKE_SYMBOL("*POINTER-SIZE*",     number_get_integer (sizeof (void *)));
	MAKE_SYMBOL("*RAND-MAX*",         number_get_integer (RAND_MAX));
#ifdef DEVELOPMENT
	MAKE_SYMBOL("*DEVELOPMENT?*",     treptr_t);
#else
	MAKE_SYMBOL("*DEVELOPMENT?*",     NIL);
#endif

    tremain_init_image_path ();
    function_init ();
    trecode_init ();
    tredebug_init_late ();

	MAKE_HOOK_SYMBOL(tremain_history, "_");
	MAKE_HOOK_SYMBOL(tremain_history_2, "__");
	MAKE_HOOK_SYMBOL(tremain_history_3, "___");

    tre_restart_fun = NIL;

	signal (SIGINT, tre_signal);

    tre_is_initialized = TRUE;
    tre_interrupt_debugger = TRUE;
}

void
tremain_init_after_image_loaded ()
{
    MAKE_SYMBOL("*LAUNCHFILE*", (tremain_launchfile ? trestring_get (tremain_launchfile) : NIL));
}

void
tremain_help (void)
{
	printf (TRE_INFO
            "Usage: tre [OPTION]... [source-file]\n"
            "\n"
            " -h        Print this help message.\n"
            " -i <path> Load image file before source-file.\n"
            " -e <expr> Expressions to evaluate before any others are read.\n"
            " -n        Load default environment and make a new default image.\n"
            " -H        Print info about hard-coded limits and exit.\n"
            "\n"
            "Repository: https://github.com/SvenMichaelKlose/tre/\n");
}

void
tremain_print_hardinfo (void)
{
	printf (TRE_INFO);
	printf ("Object pointer size:        %d bytes\n", (int) sizeof (treptr));
	printf ("Object index width:         %d bits\n", (int) TREPTR_INDEX_WIDTH);
	printf ("Object type width:          %d bits\n", (int) TRETYPE_WIDTH);
	printf ("Cell size:                  %d bytes\n", (int) (sizeof (struct cons) + sizeof (treptr)));
	printf ("Max. cells:                 %d\n", NUM_LISTNODES);
	printf ("Max. atoms:                 %d\n", NUM_ATOMS);
	printf ("Max. literal symbol length: %d chars\n", TRE_MAX_SYMLEN);
	printf ("Max. literal string length: %d chars\n", TRE_MAX_STRINGLEN);
	printf ("Max. packages:              %d\n", MAX_PACKAGES);
	printf ("Cells start:                %8lX\n", (long) &conses);
	printf ("Cells end:                  %8lX\n", (long) &conses[NUM_LISTNODES]);
	printf ("Atoms start:                %8lX\n", (long) &atoms);
	printf ("Atoms end:                  %8lX\n", (long) &atoms[NUM_ATOMS]);
	printf ("Max. files:                 %d\n", TRE_FILEIO_MAX_FILES);
	printf ("Max. nested files:          %d\n", TRE_MAX_NESTED_FILES);
	exit (0);
}

void
tremain_exec_init_expr ()
{
    trestream *  s;
    treptr       x;
    char *       expr;

    if (!tremain_init_expr)
        return;

    expr = malloc (strlen (tremain_init_expr) + 1);
    strcpy (expr, tremain_init_expr);
    s = trestream_string_make (expr);
    treiostd_divert (s);
    while (!treio_eof (s)) {
        x = tremain_line (treio_reader);
        if (x != treptr_invalid)
            treprint (x);
    }
    treiostd_undivert ();
}

void
tremain_get_args (int argc, char *argv[])
{
	int  p;

    tremain_self = argv[0];

    for (p = 1; p < argc; p++) {
		char * v = argv[p];
        if (!strcmp ("-n", v))
			tremain_noimage = TRUE;
        else if (!strcmp ("-i", v))
            tremain_userimage = argv[++p];
        else if (!strcmp ("-e", v))
            tremain_init_expr = argv[++p];
        else if (!strcmp ("-H", v))
			tremain_print_hardinfo ();
        else if (!strcmp ("-h", v)) {
			tremain_help ();
            exit (0);
        } else
            tremain_launchfile = v;
    }
}

int
main (int argc, char *argv[])
{
    static int  c = 0;
    char *      path;

    tremain_get_args (argc, argv);
    tremain_init ();

    setjmp (jmp_main);
    if (c == 1)
		goto load_error;
    if (c == 2)
		goto user;
	if (tremain_noimage)
		goto load_environment_from_source;

    c = 2;
    path = tremain_userimage ? tremain_userimage : tremain_bootimage;
    if (treimage_load (path) == -2)
        treerror_norecover (treptr_invalid, "tré image '%s' has an incompatible format version.", path);
    tremain_userimage = NULL;
    tremain_exec_init_expr ();
    goto user;

load_environment_from_source:
    tremain_exec_init_expr ();
    c = 1;
    treiostd_divert (treiostd_open_file (TRE_BOOTFILE));
    tremain_init_after_image_loaded ();
    tremain ();
load_error:
    c = 2;
    treiostd_undivert ();

user:
#ifdef TRE_HAVE_COMPILED_ENV
	(void) tre_cInit ();
#endif

    if (NOT_NIL(tre_restart_fun)) {
        eval (CONS(tre_restart_fun, NIL));
        tre_restart_fun = NIL;
    }

    tremain ();

    return 0;
}
