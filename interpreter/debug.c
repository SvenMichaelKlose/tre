/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Debugger for interpreted expressions
 */

#include "lisp.h"
#include "atom.h"
#include "error.h"
#include "eval.h"
#include "print.h"
#include "debug.h"
#include "io.h"
#include "main.h"
#include "thread.h"
#include "util.h"
#include "list.h"
#include "builtin_debug.h"
#include "xxx.h"

#include <stdarg.h>
#include <ctype.h>
#include <string.h>

int      lispdebug_mode;
lispptr  lispdebug_next;
unsigned lispdebug_level;

lispptr  lispdebug_breakpoints[LISPDEBUG_MAX_BREAKPOINTS];
int      lispdebug_num_breakpoints;

/* Mirror of the function stack, since it is singly listed. */
lispptr  lispdebug_mirror_stack;

/* Current postition on the function stack. */
lispptr  lispdebug_fspos;

/*
 * Get currently evaluated function.
 */
lispptr
lispfunstack_get_named_function (lispptr fspos)
{
    lispptr  p;
    lispptr  a = lispptr_nil;

    /* Lookup first named function on the stack. */
    DOLIST(p, fspos) {
	/* Get variable of atom containing body. */
	a = lispatom_body_to_var (CAR(p));
        if (a != lispptr_nil && LISPATOM_NAME(a))
	    break; /* Atom is named. */
    }

    return a;
}

/* Print currently evaluated function with the current expression marked. */
void
lispdebug_print_function (lispptr fspos, lispptr expr)
{
    lispptr par;

    par = lispfunstack_get_named_function (fspos);
    if (par == lispptr_nil)
        lispwarn (lispptr_nil, "couldn't lookup current function");

    lispprint_highlight = expr;

    printf ("*** In %s:\n", LISPATOM_NAME(par));
    lispprint (LISPATOM_VALUE(LISPATOM_FUN(par)));

    lispprint_highlight = lispptr_nil;
}

void
lispdebug_print_current (void)
{
    lispptr pinfo = CAR(lispdebug_mirror_stack);
    lispdebug_print_function (CAR(pinfo), CDR(pinfo));
}

/* Print currently evaluated function with the current expression marked. */
void
lispdebug_print_parents (void)
{
    lispdebug_print_function (LISPCONTEXT_FUNSTACK(), LISPCONTEXT_CURRENT());
}

void
lispdebug_chk_breakpoints (lispptr expr)
{
    lispptr   fun;
    unsigned  i;

    if (!lispdebug_num_breakpoints)
        return;

    fun = CAR(expr);
    DOTIMES(i, LISPDEBUG_MAX_BREAKPOINTS) {
        if (lispdebug_breakpoints[i] == fun) {
	    lispdebug_mode = LISPDEBUGM_STEP;
            printf ("*** BREAKPOINT ***\n");
	    return;
	}
    }

    LISPDEBUG_STEP();
}

void
lispdebug_chk_next (void)
{
    if (lispdebug_next == LISPCONTEXT_FUNSTACK())
        lispdebug_mode = LISPDEBUGM_STEP;
}

const char *lispdebug_help =
    "\nExecution:\n"
    "\n"
    " s    Step into function.\n"
    " n    Execute expression including arguments.\n"
    " x    Invoke command-line for execution of single LISP expression.\n"
    " c    Continue execution.\n"
    " u    Step to parent function.\n"
    " d    Step to child function.\n"
    " *    Set replacement value for erroranoeous expression.\n"
    "\n"
    "Breakpoints and watch expressions:\n"
    "\n"
    " b S  Set breakpoint for function S. Prints names of breakpointed\n"
    "      functions if no arguments are given.\n"
    " k S  Removes breakpoint for symbol S. If no symbol is given, your're\n"
    "      asked if all breakpoints should be removed.\n"
    "\n"
    "Printing:\n"
    "\n"
    " p S  Print contents of symbols S. If p is missing, the current function\n"
    "      is printed.\n"
    " t    Print function call backtrace.\n"
    "\n"
    "Miscellaneous:\n"
    "\n"
    " q    Quit debugger.\n";

unsigned  lispdebug_argc;
char      *lispdebug_argv[LISPDEBUG_MAX_ARGS];
char      lispdebug_argvbuf[256];

void
lispdebug_prompt (void)
{
    printf (":%d] ", lispdebug_level);
}

void
lispdebug_split_args (char *ap)
{
    unsigned  i = 0;
    char      *d = lispdebug_argvbuf;

    while (*ap >= ' ' && i < LISPDEBUG_MAX_ARGS) {
        /* Skip whitespaces. */
        while (*ap == ' ')
            ap++;
        
        /* Break at end of line. */
        if (*ap < ' ')
            break;
       
        /* Save argument position. */
        lispdebug_argv[i++] = d;
       
        /* Copy argument. */
        while (*ap != 0 && *ap > ' ')
            *d++ = toupper (*ap++);
        *d++ = 0;
    }

    lispdebug_argc = i;
    lispdebug_argv[i] = NULL;
}

void
lispdebug_read_args (void)
{
    char  line[256];

    lispio_getline (lispio_console, line, 256);
    lispdebug_split_args (line);
}

bool
lispdebug_set_breakpoint (char *name)
{
    lispptr   atom;
    lispptr   fatom;
    unsigned  i;

    atom = lispatom_seek (name, LISPCONTEXT_PACKAGE());
    if (atom == lispptr_nil) {
        printf ("Couldn't breakpoint unknown atom %s.\n", name);
        return FALSE;
    }

    DOTIMES(i, LISPDEBUG_MAX_BREAKPOINTS)
        if (lispdebug_breakpoints[i] == lispptr_nil)
   	    break;

    if (i == LISPDEBUG_MAX_BREAKPOINTS) {
        printf ("Number of maximum breakpoints exceeded.\n");
        return FALSE;
    }

    if (LISPPTR_IS_VARIABLE(atom))
        fatom = LISPATOM_FUN(atom);
    else
        fatom = atom;

    if (!(LISPPTR_IS_FUNCTION(fatom) || LISPPTR_IS_BUILTIN(fatom) ||
	LISPPTR_IS_SPECIAL(fatom))) {
        printf ("Oject '%s' is not a function.\n", name);
        return FALSE;
    }

    lispdebug_breakpoints[i] = atom;
    lispdebug_num_breakpoints++;
    return TRUE;
}

bool
lispdebug_remove_breakpoint (char *name)
{
    bool      c = FALSE;
    unsigned  j;

    DOTIMES(j, LISPDEBUG_MAX_BREAKPOINTS) {
        if (!strcmp (name, LISPATOM_NAME(lispdebug_breakpoints[j]))) {
	    lispdebug_breakpoints[j] = lispptr_nil;
	    c = TRUE;
	}
    }

    if (!c)
	printf ("No breakpoint for %s found.\n", name);
    else
        lispdebug_num_breakpoints--;

    return c;
}

/* User command: set breakpoint. */
void
lispdebug_breakpoint (void)
{
    unsigned  i;
    unsigned  a;

    lispdebug_read_args ();
    if (lispdebug_argc == 0) {
        printf ("Currently set breakpoints: ");
        i = 0;
	DOTIMES(a, LISPDEBUG_MAX_BREAKPOINTS)
            if (lispdebug_breakpoints[i] != lispptr_nil) {
 	        printf ("%s ", LISPATOM_NAME(lispdebug_breakpoints[a]));
		i++;
	    }
        if (!i) {
            printf ("none.\n");
	    return;
 	}
 	printnl ();
	return;
    }

    DOTIMES(a, lispdebug_argc)
	if (!lispdebug_set_breakpoint (lispdebug_argv[a]))
	    return;
}

/* Delete all breakpoints. */
void
lispdebug_breakpoints_delete_all (void)
{
    unsigned  i;

    DOTIMES(i, LISPDEBUG_MAX_BREAKPOINTS) {
        if (lispdebug_breakpoints[i] != lispptr_nil)
 	    printf ("%s ", LISPATOM_NAME(lispdebug_breakpoints[i]));
        lispdebug_breakpoints[i] = lispptr_nil;
    }
}

void
lispdebug_breakpoints_delete (void)
{
    unsigned  i;
    unsigned  a;
    char      c;

    lispdebug_read_args ();
 
    i = 0;
    DOTIMES(a, LISPDEBUG_MAX_BREAKPOINTS)
        if (lispdebug_breakpoints[a] != lispptr_nil)
	    i++;
    if (i == 0) {
        printf ("No breakpoints that could be deleted.\n");
        return;
    }

    /* Delete all breakpoints. */
    if (lispdebug_argc == 0) {
	printf ("Delete all breakpoints?: ");
	c = lispio_getc (lispio_console);
	printf ("\nDeleted breakpoints: ");
        if (c == 'y' || c == 'Y')
	    lispdebug_breakpoints_delete_all ();
	printnl ();
	return;
    }

    /* Remove breakpoints specified by arguments. */
    DOTIMES(i, lispdebug_argc) {
        if (!lispdebug_remove_breakpoint (lispdebug_argv[i])) {
            printf ("Symbol %s not breakpointed.\n", lispdebug_argv[i]);
	    return;
        }
   }
}

void
lispdebug_print (void)
{
    lispptr   atom;
    unsigned  i;

    lispdebug_read_args ();

    if (lispdebug_argc == 0) {
	lispdebug_print_current ();
	return;
    }

    DOTIMES(i, lispdebug_argc) {
	atom = lispatom_seek (lispdebug_argv[i], LISPCONTEXT_PACKAGE());
        if (atom == ATOM_NOT_FOUND) {
	    printf ("Symbol not found.\n");
	    return;
	}
        printf ("Value of symbol '%s':\n", LISPATOM_NAME(atom));
	lispprint (LISPATOM_VALUE(atom));
        printf ("Function of symbol '%s':\n", LISPATOM_NAME(atom));
	lispprint (LISPATOM_FUN(atom));
    }
}

/*
 * Get first named function parent to the function stack position given.
 */
lispptr
lispdebug_parent_funstack (lispptr fspos)
{
    lispptr  tmp;
    lispptr  body;

    /*
     * Step up, so we don't get stuck if the current stack position
     * contains a named function.
     */
    fspos = CDR(fspos);
    tmp = lispfunstack_get_named_function (fspos);
    RETURN_NIL(tmp);
    body = CADR(LISPATOM_VALUE(LISPATOM_FUN(tmp)));

    /* Get function stack slot, which points to the atom body. */
    while (fspos != lispptr_nil && CAR(fspos) != body)
        fspos = CDR(fspos);

    if (fspos == lispptr_nil)
	lisperror_internal (fspos, "lispdebug_parent_funstack() SFY");

    return fspos;
}

void
lispdebug_lookup_bodyname (lispptr body)
{
    lispptr  var;
    lispptr  tmp;
    static lispptr   former_fun = (lispptr) 0;
    static unsigned  repetitions = 0;
    bool            does_repeat;

    var = lispatom_body_to_var (body);
    if (var == lispptr_nil)
	return;

    tmp = body;
    does_repeat = (former_fun == var);

    if (does_repeat)
	repetitions++;
    else
        former_fun = var;

    if (repetitions > 0 && does_repeat)
	return;

    printf ("%s ", LISPATOM_NAME(var));

    if (!does_repeat) {
        if (repetitions > 0)
            printf ("(%d times) ", repetitions + 1);
	repetitions = 0;
    }
}

bool
has_funstack (void)
{
    if (LISPCONTEXT_FUNSTACK() == lispptr_nil) {
        printf ("No function stack.\n");
        return FALSE;
    }
    return TRUE;
}

void
lispdebug_trace (void)
{
    lispptr  st = LISPCONTEXT_FUNSTACK();
    lispptr  i;

    if (!has_funstack ())
        return;

    printf ("Function-call backtrace:\n");
    DOLIST(i, st)
        lispdebug_lookup_bodyname (CAR(i));
    printnl ();
}

/*
 * Initialize mirror stack
 *
 * The mirror stack enables the debugger to step backwards along the
 * singly-linked function stack. It contains references to function stack
 * elements in reverse order. When moving up a function, the current function
 * stack position is pushed onto the mirror stack. When moving back down
 * again, the position is pop'ed from the mirror stack.
 */
void
lispdebug_init_mirror_stack (void)
{
    lispdebug_fspos = LISPCONTEXT_FUNSTACK();
    lispdebug_mirror_stack =
        (LISPCONTEXT_FUNSTACK() == lispptr_nil) ?
        lispptr_nil :
        CONS(CONS(LISPCONTEXT_FUNSTACK(), LISPCONTEXT_CURRENT()), lispptr_nil);
}

void            
lispdebug_up (void)
{           
    lispptr  tmp;
    lispptr  expr;

    if (!has_funstack ())
        return;

    tmp = lispdebug_parent_funstack (lispdebug_fspos);

    if (tmp == lispptr_nil) {
        printf ("Already at top-level.\n");
	return;
    }
    expr = CAR(CDR(tmp));
    lispdebug_fspos = tmp;

    /* Save current position on mirror stack. */
    LISPLIST_PUSH(lispdebug_mirror_stack, CONS(tmp, expr));

    lispdebug_print_function (tmp, expr);
}           

void            
lispdebug_down (void)
{ 
    lispptr  child;
    lispptr  fspos;
    lispptr  expr;

    if (!has_funstack ())
        return;

    /* Check if we can go down any further. */
    if (CDR(lispdebug_mirror_stack) == lispptr_nil) {
        printf ("Already at current expression.\n");
        return;
    }

    /* Discard current entry. */
    LISPLIST_POP(lispdebug_mirror_stack);

    child = CAR(lispdebug_mirror_stack);
    fspos = CAR(child);
    expr = CDR(child);
    lispdebug_print_function (fspos, expr);
}

lispptr
lispdebug (void)
{
    lispptr  ret = 0;
    int      c;

    static int f_print = FALSE;

    if (f_print)
        lispdebug_print ();
    f_print = FALSE;

    lispdebug_mode = 0;
    lispdebug_level++;
    lispdebug_next = lispptr_nil;
    lispdebug_init_mirror_stack ();

    while (1) {
        if (ret) {
            printf ("Return value:\n");
	    lispprint (ret);
        }

        lispdebug_prompt ();
	lispio_skip_spaces (lispio_console);
        c = lispio_getc (lispio_console);
        if (lispio_eof (lispio_console))
            lisp_exit (-1);

        switch (c) {
	    case 's':
	        lispdebug_mode = LISPDEBUGM_STEP;
		lispdebug_level--;
                f_print = TRUE;
		goto end;

	    case 'n':
	        lispdebug_next = LISPCONTEXT_FUNSTACK();
		lispdebug_level--;
                f_print = TRUE;
		goto end;

	    case 'c':
		lispdebug_level--;
		printf ("Continuing...\n");
		goto end;

            case 'u':
                lispdebug_up ();
		continue;

            case 'd':
                lispdebug_down ();
		continue;

	    case 'h':
		printf (lispdebug_help);
		continue;

	    case 't':
                lispdebug_trace ();
	        continue;

	    case 'x':
	        lispdebug_mode = LISPDEBUGM_STEP;
		lisp_main_line (lispio_console);
		continue;

	    case '*':
		ret = lisp_main_line (lispio_console);
		continue;

	    case 'b':
	        lispdebug_breakpoint ();
		continue;

	    case 'k':
	        lispdebug_breakpoints_delete ();
		continue;

	    case 'p':
	        lispdebug_print ();
		continue;

	    case 'q':
		printf ("Terminating program.\n");
		lispdebug_level = 0;
                lispdebug_builtin_end_debug (lispptr_nil);

	    default:
		printf ("Unknown command '%c'. Type 'h' for help.\n", c);
        }
    }

end:
    fflush (stdout);
    return ret ? ret : lispptr_nil;
}

void
lispdebug_init (void)
{
    unsigned  i;

    lispdebug_mode = 0;
    lispdebug_next = lispptr_nil;
    lispdebug_num_breakpoints = 0;

    DOTIMES(i, LISPDEBUG_MAX_BREAKPOINTS)
        lispdebug_breakpoints[i] = lispptr_nil;

    lispdebug_level = 0;
}
