/*
 * TRE interpreter
 * Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
 *
 * Top-level control
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "io.h"
#include "io_std.h"
#include "read.h"
#include "gc.h"
#include "special.h"
#include "print.h"
#include "eval.h"
#include "builtin.h"
#include "macro.h"
#include "debug.h"
#include "thread.h"
#include "error.h"
#include "argument.h"
#include "alloc.h"
#include "symbol.h"
#include "string2.h"
#include "image.h"
#include "util.h"
#include "diag.h"
#include "dot.h"
#include "quasiquote.h"
#include "builtin_list.h"

#ifdef TRE_HAVE_COMPILED_ENV
	treptr compiled_cInit (void);
#endif

#include <setjmp.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>

char * tremain_self = NULL;   /* Path to running executable. */
char * tremain_imagelaunch = NULL;
char * tremain_launchfile = NULL;

treptr tremain_history;
treptr tremain_history_2;
treptr tremain_history_3;

bool tremain_noimage = FALSE;

struct tremain_arg {
    char * option;
    char ** value;
} tremain_args[] = {
    { "-i", &tremain_imagelaunch}
};

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
		if (! tre_interrupt_debugger)
#ifdef TRE_EXIT_ON_STDIO_SIGINT
			exit (-1);
#else
			break;
#endif
		printf ("*USER-BREAK*");
		fflush (stdout);
		tredebug_mode = TREDEBUGM_STEP;
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

		/* Dot expansion. */
		tregc_push (expr);
		expr = tredot_expand (expr);

    	/* Expand macros. */
    	expr = tremacro_builtin_macroexpand (CONS(expr, treptr_nil));

		/* QUASIQUOTE expansion. */
		tregc_push (expr);
		expr = trequasiquote_expand (expr);

		tregc_pop ();
		tregc_pop ();
    } while (!trelist_equal (expr, old));

    return expr;
}

treptr
tre_main_line (struct tre_stream *stream)
{
    treptr  expr;

    /* Read expression. */
    expr = treread (stream);
    if (expr == treptr_invalid)  /* End of file. */
        return expr;

#ifdef TRE_VERBOSE_READ
    treprint (expr);
#endif

	/* The stdin prompt may have disabled the debugger. */
	tre_interrupt_debugger = TRUE;

    tregc_push (expr);

	/* Update history. */
/*
	TREATOM_VALUE(tremain_history_3) = TREATOM_VALUE(tremain_history_2);
	TREATOM_VALUE(tremain_history_2) = TREATOM_VALUE(tremain_history);
	TREATOM_VALUE(tremain_history) = expr;
*/

	tregc_push (expr);
	expr = tremain_expand (expr);

#ifdef TRE_PRINT_MACROEXPANSIONS
    treprint (expr);
#endif

    /* Evaluate expression. */
    tregc_push (expr);
	trethread_push_call (tremain_history);
    expr = treeval (expr);
	trethread_pop_call ();
    tregc_pop ();
    tregc_pop ();
    tregc_pop ();

    /* Print result on stdout if expression was read from stdin. */
    if (treio_readerstreamptr == 1)
        treprint (expr);

    return expr;
}

void
tre_main (void)
{
    while (1)
        if (tre_main_line (treio_reader) == treptr_invalid)
	    	break;
}

treptr * trestack;
treptr * trestack_top;
treptr * trestack_ptr;

/* Initialise everything. */
void
tre_init (void)
{
    tre_is_initialized = FALSE;
    tre_interrupt_debugger = FALSE;

	trestack = malloc (sizeof (treptr) * TRESTACK_SIZE);
	trestack_top = trestack_ptr = &trestack[TRESTACK_SIZE];

    treio_init ();
    tredebug_init ();
    trethread_make ();
    tregc_init ();
#ifdef TRE_DIAGNOSTICS
    trediag_init ();
#endif

    trelist_init ();
    tresymbol_init ();
    treatom_init ();
    trenumber_init ();
    treread_init ();
    trearg_init ();
    treeval_init ();
    tremacro_init ();
    trequasiquote_init ();
    tredot_init ();
    trespecial_init ();
    treimage_init ();
    trelist_builtin_init ();

#ifdef TRE_BUILTIN_MEMBER
    MAKE_VAR("*BUILTIN-MEMBER*", treptr_t);
#endif
#ifdef TRE_BUILTIN_ASSOC
    MAKE_VAR("*BUILTIN-ASSOC*", treptr_t);
#endif

    MAKE_VAR("*KERNEL-IDENT*", trestring_get (TRE_KERNEL_IDENT));
    MAKE_VAR("*SYSTEM-NAME*", trestring_get (TRE_SYSTEM_NAME));
    MAKE_VAR("*CPU-TYPE*", trestring_get (TRE_CPU_TYPE));
    MAKE_VAR("*OS-RELEASE*", trestring_get (TRE_OS_RELEASE));
    MAKE_VAR("*OS-VERSION*", trestring_get (TRE_OS_VERSION));

    MAKE_VAR("*ENVIRONMENT-PATH*", trestring_get (TRE_ENVIRONMENT));

	MAKE_VAR("*BOOT-IMAGE*", trestring_get (TRE_BOOT_IMAGE));
	MAKE_VAR("*LIBC-PATH*", trestring_get (LIBC_PATH));
	MAKE_VAR("*ENDIANESS*", treatom_alloc (TRE_ENDIANESS_STRING, TRECONTEXT_PACKAGE(), TRETYPE_VARIABLE, treptr_invalid));
	MAKE_VAR("*POINTER-SIZE*", treatom_number_get (sizeof (void *), TRENUMTYPE_INTEGER));

	MAKE_HOOK_VAR(tremain_history, "_");
	MAKE_HOOK_VAR(tremain_history_2, "__");
	MAKE_HOOK_VAR(tremain_history_3, "___");

    tre_restart_fun = treptr_nil;

	signal (SIGINT, tre_signal);

    tre_is_initialized = TRUE;
    tre_interrupt_debugger = TRUE;
}

void
tremain_init_after_image_loaded ()
{
    /* Create global %LAUNCHFILE variable containing the application file
     * to evaluate after the environment is set up. */
    MAKE_VAR("%LAUNCHFILE", (tremain_launchfile ?
                				trestring_get (tremain_launchfile) :
                				treptr_nil));
}

void
tremain_help (void)
{
	printf (TRE_INFO
			TRE_COPYRIGHT
            "Usage: tre [-h] [-i image-file] [source-file]\n"
            "\n"
            " -h  Print this help message.\n"
            " -i  Load image file before source-file.\n"
            " -n  Make new default image.\n"
            " -H  Print hard info and exit.\n"
            "\n"
            "See MANUAL for details.\n");
}

void
tremain_print_hardinfo (void)
{
	printf (TRE_INFO TRE_COPYRIGHT);
	printf ("Max. cells: %d\n", NUM_LISTNODES);
	printf ("Max. atoms: %d\n", NUM_ATOMS);
	printf ("Max. numbers: %d\n", NUM_NUMBERS);
	printf ("Max. symbol length: %d characters\n", TRE_MAX_SYMLEN);
	printf ("Max. string length: %d characters\n", TRE_MAX_STRINGLEN);
	printf ("Max. packages: %d\n", MAX_PACKAGES);
	printf ("Cells start: %8lX\n", (ulong) &tre_lists);
	printf ("Cells end:   %8lX\n", (ulong) &tre_lists[NUM_LISTNODES]);
	printf ("Atoms start: %8lX\n", (ulong) &tre_atoms);
	printf ("Atoms end:   %8lX\n", (ulong) &tre_atoms[NUM_ATOMS]);
	printf ("Nums start:  %8lX\n", (ulong) &tre_numbers);
	printf ("Nums end:    %8lX\n", (ulong) &tre_numbers[NUM_NUMBERS]);

	printf ("Max. files: %d\n", TRE_FILEIO_MAX_FILES);
	printf ("Max. nested files (interpreter): %d\n", TRE_MAX_NESTED_FILES);
	exit (0);
}

void
tremain_get_args (int argc, char *argv[])
{
    unsigned  i;
	int  p;

    tremain_self = argv[0];

    for (p = 1; p < argc; p++) {
		char * v = argv[p];
        if (!strcmp ("-n", v)) {
			tremain_noimage = TRUE;
			continue;
		}
        if (!strcmp ("-h", v)) {
			tremain_help ();
            exit (0);
        }
        if (!strcmp ("-H", v))
			tremain_print_hardinfo ();
        DOTIMES(i, sizeof tremain_args / sizeof (struct tremain_arg)) {
            if (!strcmp (tremain_args[i].option, v)) {
                * tremain_args[i].value = argv[++p];
                goto next;
            }
        }
        tremain_launchfile = v;
next:
        continue;
    }
}

/* Program entry point. */
int
main (int argc, char *argv[])
{
    static int c = 0;

    tremain_get_args (argc, argv);
    tre_init ();

    /* Return here on errors. */
    setjmp (jmp_main);
    if (c == 1)
		goto load_error;
    if (c == 2)
		goto user;

	if (tremain_noimage)
		goto boot;

    c = 2;
    treimage_load (tremain_imagelaunch ? tremain_imagelaunch : TRE_BOOT_IMAGE);
    tremain_imagelaunch = NULL;

boot:
    /* Execute boot code. */
    c = 1;
    treiostd_divert (treiostd_open_file (TRE_BOOTFILE));
    tremain_init_after_image_loaded ();

    tre_main ();

load_error:
    c = 2;
    treiostd_undivert ();

user:
#ifdef TRE_HAVE_COMPILED_ENV
	(void) compiled_cInit ();
#endif
	/* Call init function. */
    if (tre_restart_fun != treptr_nil) {
        treeval (CONS(tre_restart_fun, treptr_nil));
        tre_restart_fun = treptr_nil;
    }

    /* Start the toplevel eval loop. */
    tre_main ();

    return 0;
}

void
tre_fnord2 (long a, long b, long c, long d, long e, long f, long g)
{
	exit (0);
}

void
tre_fnord ()
{
	tre_fnord2 (1, 2, 3,4 ,5, 6, 7);
}
