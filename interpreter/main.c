/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Top-level control
 */

#include "lisp.h"
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

char *lispmain_self = NULL;   /* Path to running executable. */
char *lispmain_imagelaunch = NULL;
char *lispmain_launchfile = NULL;

struct lispmain_arg {
    char *option;
    char **value;
} lispmain_args[] = {
    { "-i", &lispmain_imagelaunch}
};

jmp_buf jmp_main;
lispptr lisp_restart_fun;

int lisp_is_initialized;

void
lisp_exit (int code)
{
    exit (code);
}

void
lisp_restart (lispptr fun)
{
    lisp_restart_fun = fun;
    lispiostd_undivert_all ();
    longjmp (jmp_main, -1);
}

lispptr
lisp_main_line (struct lisp_stream *stream)
{
    lispptr  expr;

    /* Read expression. */
    expr = lispread (stream);
    if (expr == lispptr_invalid)  /* End of file. */
        return expr;

#ifdef LISP_VERBOSE_READ
    lispprint (expr);
#endif

    /* Expand macros. */
    lispgc_push (expr);
    expr = lispmacro_builtin_macroexpand (expr);
    lispgc_pop ();

#ifdef LISP_PRINT_MACROEXPANSIONS
    lispprint (expr);
#endif

    /* Evaluate expression. */
    lispgc_push (expr);
    expr = lispeval (expr);
    lispgc_pop ();

    /* Print result on stdout if expression was read from stdin. */
    if (lispio_readerstreamptr == 1)
        lispprint (expr);

    return expr;
}

void
lisp_main (void)
{
    while (1)
        if (lisp_main_line (lispio_reader) == lispptr_invalid)
	    break;
}

/* Initialise everything. */
void
lisp_init (void)
{
    lisp_is_initialized = FALSE;

    lispio_init ();
    lispdebug_init ();
    lispthread_make ();
    lispgc_init ();

    lisplist_init ();
    lispsymbol_init ();
    lispatom_init ();
    lispnumber_init ();
    lispread_init ();
    lisparg_init ();
    lispeval_init ();
    lispmacro_init ();
    lispspecial_init ();
    lispimage_init ();

    EXPAND_UNIVERSE(
        lispatom_alloc ("*ENVIRONMENT-PATH*", LISPCONTEXT_PACKAGE(), ATOM_VARIABLE,
                        lispstring_get (LISP_ENVIRONMENT)));

    /* Create global %LAUNCHFILE variable containing the application file
     * to evaluate after the environment is set up. */
    EXPAND_UNIVERSE(
        lispatom_alloc (
            "%LAUNCHFILE", LISPCONTEXT_PACKAGE(), ATOM_VARIABLE,
            (lispmain_launchfile ?
                lispstring_get (lispmain_launchfile) :
                lispptr_nil)));

    EXPAND_UNIVERSE(
        lispatom_alloc (
            "*BOOT-IMAGE*", LISPCONTEXT_PACKAGE(), ATOM_VARIABLE,
            lispstring_get (LISP_BOOT_IMAGE)));

    lisp_restart_fun = lispptr_nil;
    lisp_is_initialized = TRUE;
}

void
lispmain_get_args (int argc, char *argv[])
{
    unsigned  i;
    int       p = 1;

    lispmain_self = argv[0];

    while (p < argc) {
        if (!strcmp ("-h", argv[p])) {
            printf (LISP_COPYRIGHT
                    "Usage: lisp [-h] [-i image-file] [source-file]\n"
                    "\n"
                    " -h  Print this help message.\n"
                    " -i  Load image file before source-file.\n"
                    "\n"
                    "See MANUAL for details.\n");
            exit (0);
        }
        DOTIMES(i, sizeof lispmain_args / sizeof (struct lispmain_arg)) {
            if (!strcmp (lispmain_args[i].option, argv[p])) {
                *lispmain_args[i].value = argv[++p];
                p++;
                goto next;
            }
        }
        lispmain_launchfile = argv[p];
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

    lispmain_get_args (argc, argv);
    lisp_init ();

    /* Return here on errors. */
    setjmp (jmp_main);
    if (c == 1)
	goto load_error;
    if (c == 2)
	goto user;

    c = 2;
    lispimage_load (lispmain_imagelaunch ? lispmain_imagelaunch : LISP_BOOT_IMAGE);
    lispmain_imagelaunch = NULL;

    /* Execute boot code. */
    c = 1;
    lispiostd_divert (lispiostd_open_file (LISP_BOOTFILE));
    lisp_main ();

load_error:
    c = 2;
    lispiostd_undivert ();

    /* Start the eval loop. */
user:
    if (lisp_restart_fun != lispptr_nil) {
        lispeval (CONS(lisp_restart_fun, lispptr_nil));
        lisp_restart_fun = lispptr_nil;
    }

    lisp_main ();

    return 0;
}
