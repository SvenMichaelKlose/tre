/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
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
#include "string.h"
#include "image.h"
#include "util.h"

#include <setjmp.h>
#include <stdlib.h>
#include <string.h>

char *tremain_self = NULL;   /* Path to running executable. */
char *tremain_imagelaunch = NULL;
char *tremain_launchfile = NULL;

struct tremain_arg {
    char *option;
    char **value;
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

void
tre_restart (treptr fun)
{
    tre_restart_fun = fun;
    treiostd_undivert_all ();
    longjmp (jmp_main, -1);
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

    /* Expand macros. */
    tregc_push (expr);
    expr = tremacro_builtin_macroexpand (expr);
    tregc_pop ();

#ifdef TRE_PRINT_MACROEXPANSIONS
    treprint (expr);
#endif

    /* Evaluate expression. */
    tregc_push (expr);
    expr = treeval (expr);
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

/* Initialise everything. */
void
tre_init (void)
{
    tre_is_initialized = FALSE;

    treio_init ();
    tredebug_init ();
    trethread_make ();
    tregc_init ();

    trelist_init ();
    tresymbol_init ();
    treatom_init ();
    trenumber_init ();
    treread_init ();
    trearg_init ();
    treeval_init ();
    tremacro_init ();
    trespecial_init ();
    treimage_init ();

    EXPAND_UNIVERSE(
        treatom_alloc ("*ENVIRONMENT-PATH*", TRECONTEXT_PACKAGE(), ATOM_VARIABLE,
                        trestring_get (TRE_ENVIRONMENT)));

    /* Create global %LAUNCHFILE variable containing the application file
     * to evaluate after the environment is set up. */
    EXPAND_UNIVERSE(
        treatom_alloc (
            "%LAUNCHFILE", TRECONTEXT_PACKAGE(), ATOM_VARIABLE,
            (tremain_launchfile ?
                trestring_get (tremain_launchfile) :
                treptr_nil)));

    EXPAND_UNIVERSE(
        treatom_alloc (
            "*BOOT-IMAGE*", TRECONTEXT_PACKAGE(), ATOM_VARIABLE,
            trestring_get (TRE_BOOT_IMAGE)));

    tre_restart_fun = treptr_nil;
    tre_is_initialized = TRUE;
}

void
tremain_get_args (int argc, char *argv[])
{
    unsigned  i;
    int       p = 1;

    tremain_self = argv[0];

    while (p < argc) {
        if (!strcmp ("-h", argv[p])) {
            printf (TRE_COPYRIGHT
                    "Usage: tre [-h] [-i image-file] [source-file]\n"
                    "\n"
                    " -h  Print this help message.\n"
                    " -i  Load image file before source-file.\n"
                    "\n"
                    "See MANUAL for details.\n");
            exit (0);
        }
        DOTIMES(i, sizeof tremain_args / sizeof (struct tremain_arg)) {
            if (!strcmp (tremain_args[i].option, argv[p])) {
                *tremain_args[i].value = argv[++p];
                p++;
                goto next;
            }
        }
        tremain_launchfile = argv[p];
        return;
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

    c = 2;
    treimage_load (tremain_imagelaunch ? tremain_imagelaunch : TRE_BOOT_IMAGE);
    tremain_imagelaunch = NULL;

    /* Execute boot code. */
    c = 1;
    treiostd_divert (treiostd_open_file (TRE_BOOTFILE));
    tre_main ();

load_error:
    c = 2;
    treiostd_undivert ();

    /* Start the eval loop. */
user:
    if (tre_restart_fun != treptr_nil) {
        treeval (CONS(tre_restart_fun, treptr_nil));
        tre_restart_fun = treptr_nil;
    }

    tre_main ();

    return 0;
}
