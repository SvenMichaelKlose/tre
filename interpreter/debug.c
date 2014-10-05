/*
 * tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include <stdarg.h>
#include <ctype.h>
#include <string.h>

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
#include "symbol.h"
#include "function.h"

int    tredebug_mode;
treptr tredebug_next;
size_t tredebug_level;

treptr tredebug_breakpoints[TREDEBUG_MAX_BREAKPOINTS];
int    tredebug_num_breakpoints;

treptr tredebug_mirror_stack; /* Mirror of the function stack, since it is singly listed. */

treptr tredebug_fspos; /* Current postition on the function stack. */

treptr treptr_milestone;

treptr
trefunstack_get_named_function (treptr fspos)
{
    treptr  p;
    treptr  a = treptr_nil;

    DOLIST(p, fspos) {
		a = treatom_body_to_var (CAR(p));
        if (NOT_NIL(a) && TRESYMBOL_NAME(a))
	    	break;
    }

    return a;
}

void
tredebug_print_function (treptr fspos, treptr expr)
{
    treptr par;

    par = trefunstack_get_named_function (fspos);
    if (NOT(par))
        trewarn (treptr_nil, "couldn't lookup current function");

    treprint_highlight = expr;

    printf ("*** In %s:\n", TRESYMBOL_NAME(par));
    treprint (TREFUNCTION_SOURCE(TRESYMBOL_FUN(par)));

    treprint_highlight = treptr_nil;
}

void
tredebug_print_current (void)
{
    treptr pinfo = CAR(tredebug_mirror_stack);
    tredebug_print_function (CAR(pinfo), CDR(pinfo));
}

void
tredebug_print_parents (void)
{
    tredebug_print_function (TRECONTEXT_FUNSTACK(), TRECONTEXT_CURRENT());
}

void
tredebug_chk_breakpoints (treptr expr)
{
    treptr  fun;
    size_t  i;

    if (!tredebug_num_breakpoints)
        return;

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

size_t tredebug_argc;
char * tredebug_argv[TREDEBUG_MAX_ARGS + 1];
char   tredebug_argvbuf[256];

void
tredebug_prompt (void)
{
	(void) trestream_builtin_terminal_normal (treptr_nil);
    printf (":%ld] ", (long) tredebug_level);
}

void
tredebug_split_args (char *ap)
{
    size_t  i = 0;
    char *  d = tredebug_argvbuf;

    while (*ap >= ' ' && i < TREDEBUG_MAX_ARGS) {
        while (*ap == ' ')
            ap++;
        
        if (*ap < ' ')
            break;
       
        tredebug_argv[i++] = d;
       
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
    treptr  atom;
    treptr  fatom;
    size_t  i;

    atom = treatom_seek (name, TRECONTEXT_PACKAGE());
    if (NOT(atom)) {
        printf ("Couldn't breakpoint unknown atom %s.\n", name);
        return FALSE;
    }

    DOTIMES(i, TREDEBUG_MAX_BREAKPOINTS)
        if (NOT(tredebug_breakpoints[i]))
   	        break;

    if (i == TREDEBUG_MAX_BREAKPOINTS) {
        printf ("Number of maximum breakpoints exceeded.\n");
        return FALSE;
    }

    if (SYMBOLP(atom))
        fatom = TRESYMBOL_FUN(atom);
    else
        fatom = atom;

    if (!(FUNCTIONP(fatom) || BUILTINP(fatom) || SPECIALP(fatom))) {
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
    bool    c = FALSE;
    size_t  j;

    DOTIMES(j, TREDEBUG_MAX_BREAKPOINTS) {
        if (!strcmp (name, TRESYMBOL_NAME(tredebug_breakpoints[j]))) {
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

void
tredebug_breakpoint (void)
{
    size_t  i;
    size_t  a;

    tredebug_read_args ();
    if (tredebug_argc == 0) {
        printf ("Currently set breakpoints: ");
        i = 0;
		DOTIMES(a, TREDEBUG_MAX_BREAKPOINTS) {
            if (NOT_NIL(tredebug_breakpoints[i])) {
 	        	printf ("%s ", TRESYMBOL_NAME(tredebug_breakpoints[a]));
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

void
tredebug_breakpoints_delete_all (void)
{
    size_t  i;

    DOTIMES(i, TREDEBUG_MAX_BREAKPOINTS) {
        if (NOT_NIL(tredebug_breakpoints[i]))
 	    	printf ("%s ", TRESYMBOL_NAME(tredebug_breakpoints[i]));
        tredebug_breakpoints[i] = treptr_nil;
    }
}

void
tredebug_breakpoints_delete (void)
{
    size_t  i;
    size_t  a;
    char    c;

    tredebug_read_args ();
 
    i = 0;
    DOTIMES(a, TREDEBUG_MAX_BREAKPOINTS)
        if (NOT_NIL(tredebug_breakpoints[a]))
	    	i++;

    if (i == 0) {
        printf ("No breakpoints that could be deleted.\n");
        return;
    }

    if (tredebug_argc == 0) {
		printf ("Delete all breakpoints?: ");
		c = treio_getc (treio_console);
		printf ("\nDeleted breakpoints: ");
		if (c == 'y' || c == 'Y')
	    	tredebug_breakpoints_delete_all ();
		printnl ();
		return;
	}

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
    treptr  atom;
    size_t  i;

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
        printf ("Value of symbol '%s':\n", TRESYMBOL_NAME(atom));
		treprint (TRESYMBOL_VALUE(atom));
        printf ("Function of symbol '%s':\n", TRESYMBOL_NAME(atom));
		treprint (TRESYMBOL_FUN(atom));
    }
}

treptr
tredebug_parent_funstack (treptr fspos)
{
    treptr  tmp;
    treptr  body;

    fspos = CDR(fspos);

    tmp = trefunstack_get_named_function (fspos);
    RETURN_NIL(tmp);
    body = CADR(TREFUNCTION_SOURCE(TRESYMBOL_FUN(tmp)));

    while (NOT_NIL(fspos) && CAR(fspos) != body)
        fspos = CDR(fspos);

    if (NOT(fspos))
		treerror_internal (fspos, "tredebug_parent_funstack() SFY");

    return fspos;
}

void
tredebug_lookup_bodyname (treptr body)
{
    treptr  var;
    static treptr  former_fun = (treptr) 0;
    static size_t  repetitions = 0;
    bool           does_repeat;

    var = treatom_body_to_var (body);
    if (NOT(var))
		return;

    does_repeat = (former_fun == var);

    if (does_repeat)
		repetitions++;
    else
        former_fun = var;

    if (repetitions > 0 && does_repeat)
		return;

    printf ("%s ", TRESYMBOL_NAME(var));

    if (!does_repeat) {
        if (repetitions > 0)
            printf ("(%ld times) ", (long) repetitions + 1);
		repetitions = 0;
    }
}

bool
has_funstack (void)
{
    if (NOT(TRECONTEXT_FUNSTACK())) {
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

			case TRETYPE_BUILTIN:
    			printf ("*BUILT IN FUNCTION* ");
				break;
		}
	}
    printnl ();
}

void
tredebug_init_mirror_stack (void)
{
    tredebug_fspos = TRECONTEXT_FUNSTACK();
    tredebug_mirror_stack = NOT(TRECONTEXT_FUNSTACK()) ?
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
    if (NOT(tmp)) {
        printf ("You cannot go upwards further. You're already at the current expression.\n");
		return;
    }

    expr = CAR(CDR(tmp));
    tredebug_fspos = tmp;

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

    if (NOT(CDR(tredebug_mirror_stack))) {
        printf ("You cannot go downwards further. You're already at the current expression.\n");
        return;
    }

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

		case 'u': tredebug_up (); continue;
		case 'd': tredebug_down (); continue;

	    case 'h':
			printf ("%s", tredebug_help);
			continue;

	    case 't':
			tredebug_trace ();
	        continue;

	    case 'x':
	        tredebug_mode = TREDEBUGM_STEP;
			tremain_line (treio_console);
			continue;

	    case '*':
			ret = tremain_line (treio_console);
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
    size_t  i;

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
    MAKE_SYMBOL("*MILESTONE*", treptr_nil);
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
