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

#include <setjmp.h>
#include <stdlib.h>

jmp_buf jmp_main;

int lisp_is_initialized;

void
lisp_exit (int code)
{
    exit (code);
}

void
lisp_restart (void)
{
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
lisp_init (int argc, char *argv)
{
    lispptr tmp;
    lispptr lf;

    lisp_is_initialized = FALSE;
    lisplist_init ();
    lispsymbol_init ();
    lispatom_init ();
    lispthread_make ();
    lispmacro_init ();
    lispalloc_init ();
    lispgc_init ();
    lispnumber_init ();
    lispio_init ();
    lispread_init ();
    lispeval_init ();
    lisparg_init ();
    lispspecial_init ();
    lispdebug_init ();
    lisperror_init ();

    lisp_is_initialized = TRUE;

    /* Create global %LAUNCHFILE variable containing the application file
     * to evaluate after the environment is set up. */
    lf = lispatom_get ("%LAUNCHFILE", LISPCONTEXT_PACKAGE());
    EXPAND_UNIVERSE(lf);
    if (argc == 2)
        tmp = lispstring_get (argv);
    else
	tmp = lispptr_nil;
    lispatom_set_value (lf, tmp);
}

/* Program entry point. */
int
main (int argc, char *argv[])
{
    static int c = 0;

    lisp_init (argc, argv[1]);

    /* Return here on errors. */
    setjmp (jmp_main);
    if (c == 1)
	goto load_error;
    if (c == 2)
	goto user;

    /* Execute boot code. */
    c = 1;

#ifdef LISP_DIAGNOSTICS
    printf ("Diagnostic checks enabled.\n");
#endif
#ifdef LISP_GC_DEBUG
    printf ("!!! LISP_GC_DEBUG - will run GC everywhere !!!\n");
#endif
#ifdef LISP_NO_MANUAL_FREE
    printf ("Early garbage removal OFF.\n");
#endif
#ifdef LISP_PRINT_MACROEXPANSIONS
    printf ("Macroexpansions are printed in read-eval loop.\n");
#endif
#ifdef LISP_VERBOSE_READ
    printf ("READ expressions are printed in read-eval loop.\n");
#endif
#ifdef LISP_VERBOSE_LOAD
    printf ("Booting world from file '%s'.\n", LISP_BOOTFILE);
#endif

    lispiostd_divert (lispiostd_open_file (LISP_BOOTFILE));
    lisp_main ();
load_error:
    c = 2;
    lispiostd_undivert ();

    /* Start the eval loop. */
user:
    lisp_main ();

    return 0;
}
