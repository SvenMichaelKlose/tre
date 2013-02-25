/*
 * tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "error.h"
#include "eval.h"
#include "print.h"
#include "debug.h"
#include "io.h"
#include "main.h"
#include "thread.h"
#include "util.h"
#include "builtin_debug.h"
#include "builtin_stream.h"
#include "xxx.h"
#include "gc.h"

#include <stdarg.h>
#include <ctype.h>
#include <string.h>

int      tredebug_mode;
treptr  tredebug_next;
ulong tredebug_level;

treptr  tredebug_breakpoints[TREDEBUG_MAX_BREAKPOINTS];
int      tredebug_num_breakpoints;

/* Mirror of the function stack, since it is singly listed. */
treptr  tredebug_mirror_stack;

/* Current postition on the function stack. */
treptr  tredebug_fspos;

treptr  treptr_milestone;

/*
 * Get currently evaluated function.
 */
treptr
trefunstack_get_named_function (treptr fspos)
{
    treptr  p;
    treptr  a = treptr_nil;

    /* Lookup first named function on the stack. */
    DOLIST(p, fspos) {
		/* Get variable of atom containing body. */
		a = treatom_body_to_var (CAR(p));
        if (a != treptr_nil && TREATOM_NAME(a))
	    	break; /* Atom is named. */
    }

    return a;
}

/* Print currently evaluated function with the current expression marked. */
void
tredebug_print_function (treptr fspos, treptr expr)
{
    treptr par;

    par = trefunstack_get_named_function (fspos);
    if (par == treptr_nil)
        trewarn (treptr_nil, "couldn't lookup current function");

    treprint_highlight = expr;

    printf ("*** In %s:\n", TREATOM_NAME(par));
    treprint (TREATOM_VALUE(TREATOM_FUN(par)));

    treprint_highlight = treptr_nil;
}

void
tredebug_print_current (void)
{
    treptr pinfo = CAR(tredebug_mirror_stack);
    tredebug_print_function (CAR(pinfo), CDR(pinfo));
}

/* Print currently evaluated function with the current expression marked. */
void
tredebug_print_parents (void)
{
    tredebug_print_function (TRECONTEXT_FUNSTACK(), TRECONTEXT_CURRENT());
}

void
tredebug_chk_breakpoints (treptr expr)
{
    treptr   fun;
    ulong  i;

    if (!tredebug_num_breakpoints)
        return;

	/* Seek breakpoint for expression function. */
    fun = CAR(expr);
    DOTIMES(i, TREDEBUG_MAX_BREAKPOINTS) {
        if (tredebug_breakpoints[i] == fun) {
	    	tredebug_mode = TREDEBUGM_STEP;
            printf ("*** BREAKPOINT ***\n");
	    	return;
		}
    }
}

void
tredebug_chk_next (void)
{
    if (tredebug_next == TRECONTEXT_FUNSTACK())
        tredebug_mode = TREDEBUGM_STEP;
}

const char *tredebug_help =
	"TRE debugger commands:\n"
    "Execution:\n"
    "\n"
    " s    Step into function.\n"
    " n    Execute expression including arguments.\n"
    " x    Invoke command-line for execution of single TRE expression.\n"
    " c    Continue execution.\n"
    " u    Step to parent function.\n"
    " d    Step to child function.\n"
    " *    Set replacement value for erroranoeous expression.\n"
    " q    Quit debugger and program and return to toplevel.\n"
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
    " t    Print function call backtrace.\n";

ulong  tredebug_argc;
char * tredebug_argv[TREDEBUG_MAX_ARGS + 1];
char   tredebug_argvbuf[256];

void
tredebug_prompt (void)
{
	(void) trestream_builtin_terminal_normal (treptr_nil);
    printf (":%ld] ", tredebug_level);
}

void
tredebug_split_args (char *ap)
{
    ulong  i = 0;
    char      *d = tredebug_argvbuf;

    while (*ap >= ' ' && i < TREDEBUG_MAX_ARGS) {
        /* Skip whitespaces. */
        while (*ap == ' ')
            ap++;
        
        /* Break at end of line. */
        if (*ap < ' ')
            break;
       
        /* Save argument position. */
        tredebug_argv[i++] = d;
       
        /* Copy argument. */
        while (*ap != 0 && *ap > ' ')
            *d++ = toupper (*ap++);
        *d++ = 0;
    }

    tredebug_argc = i;
    tredebug_argv[i] = NULL;
}

void
tredebug_read_args (void)
{
    char  line[256];

    treio_getline (treio_console, line, 256);
    tredebug_split_args (line);
}

bool
tredebug_set_breakpoint (char *name)
{
    treptr   atom;
    treptr   fatom;
    ulong  i;

    atom = treatom_seek (name, TRECONTEXT_PACKAGE());
    if (atom == treptr_nil) {
        printf ("Couldn't breakpoint unknown atom %s.\n", name);
        return FALSE;
    }

    DOTIMES(i, TREDEBUG_MAX_BREAKPOINTS)
        if (tredebug_breakpoints[i] == treptr_nil)
   	    break;

    if (i == TREDEBUG_MAX_BREAKPOINTS) {
        printf ("Number of maximum breakpoints exceeded.\n");
        return FALSE;
    }

    if (TREPTR_IS_VARIABLE(atom))
        fatom = TREATOM_FUN(atom);
    else
        fatom = atom;

    if (!(TREPTR_IS_FUNCTION(fatom) || TREPTR_IS_BUILTIN(fatom) ||
	TREPTR_IS_SPECIAL(fatom))) {
        printf ("Oject '%s' is not a function.\n", name);
        return FALSE;
    }

    tredebug_breakpoints[i] = atom;
    tredebug_num_breakpoints++;
    return TRUE;
}

bool
tredebug_remove_breakpoint (char *name)
{
    bool      c = FALSE;
    ulong  j;

    DOTIMES(j, TREDEBUG_MAX_BREAKPOINTS) {
        if (!strcmp (name, TREATOM_NAME(tredebug_breakpoints[j]))) {
	    	tredebug_breakpoints[j] = treptr_nil;
	    	c = TRUE;
		}
    }

    if (!c)
		printf ("No breakpoint for %s found.\n", name);
    else
        tredebug_num_breakpoints--;

    return c;
}

/* User command: set breakpoint. */
void
tredebug_breakpoint (void)
{
    ulong  i;
    ulong  a;

    tredebug_read_args ();
    if (tredebug_argc == 0) {
        printf ("Currently set breakpoints: ");
        i = 0;
		DOTIMES(a, TREDEBUG_MAX_BREAKPOINTS) {
            if (tredebug_breakpoints[i] != treptr_nil) {
 	        	printf ("%s ", TREATOM_NAME(tredebug_breakpoints[a]));
				i++;
	    	}
		}
       	if (!i) {
           	printf ("none.\n");
	   		return;
 		}
 		printnl ();
		return;
    }

    DOTIMES(a, tredebug_argc)
		if (!tredebug_set_breakpoint (tredebug_argv[a]))
	    	return;
}

/* Delete all breakpoints. */
void
tredebug_breakpoints_delete_all (void)
{
    ulong  i;

    DOTIMES(i, TREDEBUG_MAX_BREAKPOINTS) {
        if (tredebug_breakpoints[i] != treptr_nil)
 	    	printf ("%s ", TREATOM_NAME(tredebug_breakpoints[i]));
        tredebug_breakpoints[i] = treptr_nil;
    }
}

void
tredebug_breakpoints_delete (void)
{
    ulong  i;
    ulong  a;
    char      c;

    tredebug_read_args ();
 
    i = 0;
    DOTIMES(a, TREDEBUG_MAX_BREAKPOINTS)
        if (tredebug_breakpoints[a] != treptr_nil)
	    	i++;

    if (i == 0) {
        printf ("No breakpoints that could be deleted.\n");
        return;
    }

    /* Delete all breakpoints. */
    if (tredebug_argc == 0) {
		printf ("Delete all breakpoints?: ");
		c = treio_getc (treio_console);
		printf ("\nDeleted breakpoints: ");
		if (c == 'y' || c == 'Y')
	    	tredebug_breakpoints_delete_all ();
		printnl ();
		return;
	}

    /* Remove breakpoints specified by arguments. */
    DOTIMES(i, tredebug_argc) {
        if (!tredebug_remove_breakpoint (tredebug_argv[i])) {
            printf ("Symbol %s not breakpointed.\n", tredebug_argv[i]);
			return;
		}
	}
}

void
tredebug_print (void)
{
    treptr   atom;
    ulong  i;

    tredebug_read_args ();

    if (tredebug_argc == 0) {
		tredebug_print_current ();
		return;
    }

    DOTIMES(i, tredebug_argc) {
	atom = treatom_seek (tredebug_argv[i], TRECONTEXT_PACKAGE());
        if (atom == ATOM_NOT_FOUND) {
	    	printf ("Symbol not found.\n");
	    	return;
		}
        printf ("Value of symbol '%s':\n", TREATOM_NAME(atom));
		treprint (TREATOM_VALUE(atom));
        printf ("Function of symbol '%s':\n", TREATOM_NAME(atom));
		treprint (TREATOM_FUN(atom));
    }
}

/*
 * Get first named function parent to the function stack position given.
 */
treptr
tredebug_parent_funstack (treptr fspos)
{
    treptr  tmp;
    treptr  body;

    /*
     * Step up, so we don't get stuck if the current stack position
     * contains a named function.
     */
    fspos = CDR(fspos);

    tmp = trefunstack_get_named_function (fspos);
    RETURN_NIL(tmp);
    body = CADR(TREATOM_VALUE(TREATOM_FUN(tmp)));

    /* Get function stack slot, which points to the atom body. */
    while (fspos != treptr_nil && CAR(fspos) != body)
        fspos = CDR(fspos);

    if (fspos == treptr_nil)
		treerror_internal (fspos, "tredebug_parent_funstack() SFY");

    return fspos;
}

void
tredebug_lookup_bodyname (treptr body)
{
    treptr  var;
    static treptr   former_fun = (treptr) 0;
    static ulong  repetitions = 0;
    bool            does_repeat;

    var = treatom_body_to_var (body);
    if (var == treptr_nil)
		return;

    does_repeat = (former_fun == var);

    if (does_repeat)
		repetitions++;
    else
        former_fun = var;

    if (repetitions > 0 && does_repeat)
		return;

    printf ("%s ", TREATOM_NAME(var));

    if (!does_repeat) {
        if (repetitions > 0)
            printf ("(%ld times) ", repetitions + 1);
		repetitions = 0;
    }
}

bool
has_funstack (void)
{
    if (TRECONTEXT_FUNSTACK() == treptr_nil) {
        printf ("No function stack.\n");
        return FALSE;
    }
    return TRUE;
}

void
tredebug_trace (void)
{
    treptr  st = TRECONTEXT_FUNSTACK();
    treptr  i;
    treptr  x;

    if (!has_funstack ())
        return;

    printf ("Function-call backtrace:\n");
    DOLIST(i, st) {
		fflush (stdout);
		x = CAR(i);

		switch (TREPTR_TYPE(x)) {
			case TRETYPE_CONS:
			case TRETYPE_FUNCTION:
			case TRETYPE_USERSPECIAL:
			case TRETYPE_MACRO:
        		tredebug_lookup_bodyname (x);
				break;

			/* built-in functions don't recurse. */
			case TRETYPE_BUILTIN:
    			printf ("%s ", TREATOM_NAME(x));
				break;
		}
	}
    printnl ();
}

/*
 * Initialize mirror stack
 *
 * The mirror stack enables the debugger to step backwards along the
 * singly-linked function stack. It contains references to function stack
 * elements in reverse order. When moving up a function, the current function
 * stack position is pushed onto the mirror stack. When moving back down
 * again, the position is pop'ed from the mirror stack. The original funstack
 * remains untouched.
 */
void
tredebug_init_mirror_stack (void)
{
    tredebug_fspos = TRECONTEXT_FUNSTACK();
    tredebug_mirror_stack =
        (TRECONTEXT_FUNSTACK() == treptr_nil) ?
        treptr_nil :
        CONS(CONS(TRECONTEXT_FUNSTACK(), TRECONTEXT_CURRENT()), treptr_nil);
}

void            
tredebug_up (void)
{           
    treptr  tmp;
    treptr  expr;

    if (!has_funstack ())
        return;

    tmp = tredebug_parent_funstack (tredebug_fspos);
    if (tmp == treptr_nil) {
        printf ("Already at top-level.\n");
		return;
    }
    expr = CAR(CDR(tmp));
    tredebug_fspos = tmp;

    /* Save current position on mirror stack. */
    TRELIST_PUSH(tredebug_mirror_stack, CONS(tmp, expr));

    tredebug_print_function (tmp, expr);
}           

void            
tredebug_down (void)
{ 
    treptr  child;
    treptr  fspos;
    treptr  expr;

    if (!has_funstack ())
        return;

    /* Check if we can go down any further. */
    if (CDR(tredebug_mirror_stack) == treptr_nil) {
        printf ("Already at current expression.\n");
        return;
    }

    /* Discard current entry. */
    TRELIST_POP(tredebug_mirror_stack);

    child = CAR(tredebug_mirror_stack);
    fspos = CAR(child);
    expr = CDR(child);
    tredebug_print_function (fspos, expr);
}

treptr
tredebug (void)
{
    treptr  ret = 0;
    int      c;

    static int f_print = FALSE;

    if (f_print)
        tredebug_print ();
    f_print = FALSE;
	tregc_force ();

    tredebug_mode = 0;
    tredebug_level++;
    tredebug_next = treptr_nil;
    tredebug_init_mirror_stack ();

    while (1) {
        if (ret) {
            printf ("Return value:\n");
	    	treprint (ret);
        }

        tredebug_prompt ();
		treio_skip_spaces (treio_console);
        c = treio_getc (treio_console);
        if (treio_eof (treio_console))
            tre_exit (-1);

        switch (c) {
	    case 's':
	        tredebug_mode = TREDEBUGM_STEP;
			tredebug_level--;
 			f_print = TRUE;
			goto end;

	    case 'n':
	        tredebug_next = TRECONTEXT_FUNSTACK();
			tredebug_level--;
			f_print = TRUE;
			goto end;

	    case 'c':
			tredebug_level--;
			printf ("Continuing...\n");
			goto end;

		case 'u':
			tredebug_up ();
			continue;

		case 'd':
			tredebug_down ();
			continue;

	    case 'h':
			printf ("%s", tredebug_help);
			continue;

	    case 't':
			tredebug_trace ();
	        continue;

	    case 'x':
	        tredebug_mode = TREDEBUGM_STEP;
			tre_main_line (treio_console);
			continue;

	    case '*':
			ret = tre_main_line (treio_console);
			continue;

	    case 'b':
	        tredebug_breakpoint ();
			continue;

	    case 'k':
	        tredebug_breakpoints_delete ();
			continue;

	    case 'p':
	        tredebug_print ();
			continue;

	    case 'q':
			printf ("Terminating program.\n");
			tredebug_level = 0;
			tredebug_builtin_end_debug (treptr_nil);

	    default:
			printf ("Unknown command '%c'. Type 'h' for help.\n", c);
        }
    }

end:
    fflush (stdout);
    return ret ? ret : treptr_nil;
}

void
tredebug_init (void)
{
    ulong  i;

    tredebug_mode = 0;
    tredebug_next = treptr_nil;
    tredebug_num_breakpoints = 0;

    DOTIMES(i, TREDEBUG_MAX_BREAKPOINTS)
        tredebug_breakpoints[i] = treptr_nil;


    tredebug_level = 0;
}

void
tredebug_init_late (void)
{
    MAKE_VAR("*MILESTONE*", treptr_nil);
    treptr_milestone = treatom_get ("*MILESTONE*", TRECONTEXT_PACKAGE());
}

treptr
treptr_index (treptr x)
{
    return TREPTR_INDEX(x);
}

treptr
treptr_type (treptr x)
{
    return TREPTR_TYPE(x);
}

#endif /* #ifdef INTERPRETER */
