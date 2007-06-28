/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Printing LISP expressions.
 */

/*
 * Use _CAR() and _CDR() to enable debug dumps.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "print.h"
#include "error.h"
#include "util.h"
#include "eval.h"
#include "io.h"
#include "string.h"
#include "thread.h"

#include <stdio.h>
#include <strings.h>

/* List element marks. */
char lispprint_marks_cons[NUM_LISTNODES_TOTAL >> 3];
char lispprint_marks_atoms[NUM_ATOMS >> 3];

#define LISPPRINT_MARK_CONS(i) \
    LISP_MARK(lispprint_marks_cons, i)
#define LISPPRINT_GET_MARK_CONS(i) \
    LISP_GETMARK(lispprint_marks_cons, i)

#define LISPPRINT_MARK_ATOM(i) \
    LISP_MARK(lispprint_marks_atoms, LISPPTR_INDEX(i))
#define LISPPRINT_GET_MARK_ATOM(i) \
    LISP_GETMARK(lispprint_marks_atoms, LISPPTR_INDEX(i))

void
lispprint_wipe_marks (void)
{
    bzero (lispprint_marks_cons, sizeof (lispprint_marks_cons));
    bzero (lispprint_marks_atoms, sizeof (lispprint_marks_atoms));
}

void lispprint_indent (lispptr p, unsigned indent, bool nobracket, char *prepend);

bool lispprint_no_nl;

lispptr lispprint_highlight;

#define LISPPRINT_HL(x,txt) \
    if (lispprint_highlight != lispptr_nil && lispprint_highlight == x) \
        printf (txt) 

#define LISPPRINT_HLOPEN(x) \
    if (lispprint_highlight != lispptr_nil && lispprint_highlight == x) \
        printf ("===>") 
#define LISPPRINT_HLCLOSE(x) \
    if (lispprint_highlight != lispptr_nil && lispprint_highlight == x) { \
        printf ("<==="); \
	lispprint_highlight = lispptr_nil; \
    }

void lispprint_r (lispptr);

void
lispprint_array (lispptr array)
{
    lispptr   *elts = LISPATOM_DETAIL(array);
    unsigned  size = LISPNUMBER_VAL(_CAR(LISPATOM_VALUE(array)));
    unsigned  i;

    printf ("#(");

    DOTIMES(i, size) {
	lispprint_no_nl = TRUE;
        if (i)
	    printf (" ");
        lispprint_r (elts[i]);
    }

    printf (")");
}

bool
lispprint_chk_atom_mark (lispptr atom)
{
    bool mark;

    if (LISPPTR_IS_ATOM(atom)) {
        mark = LISPPRINT_GET_MARK_ATOM(atom);
        LISPPRINT_MARK_ATOM(atom);
        if (mark) {
            switch (LISPPTR_TYPE(atom)) {
	        case ATOM_FUNCTION:
	        case ATOM_MACRO:
	        case ATOM_USERSPECIAL:
                case ATOM_ARRAY:
                    return TRUE;
            }
        }
    }

    return FALSE;
}

void
lispprint_atom (lispptr atom, unsigned indent)
{
    char *name;

    if (lispprint_chk_atom_mark (atom)) {
        printf ("*circular*");
        return;
    }

    LISPPRINT_HLOPEN(atom);

    switch (LISPPTR_TYPE(atom)) {
	case ATOM_VARIABLE:
	case ATOM_BUILTIN:
	case ATOM_SPECIAL:
	    if (LISPATOM_PACKAGE(atom) != LISPCONTEXT_PACKAGE())
                printf ("%s:", LISPATOM_NAME(LISPATOM_PACKAGE(atom)));
            printf ("%s", LISPATOM_NAME(atom));
	    break;

	case ATOM_NUMBER:
	    if (LISPNUMBER_TYPE(atom) == LISPNUMTYPE_CHAR) {
		printf ("#\\");
	        putchar ((int) LISPNUMBER_VAL(atom));
	    } else
                printf ("%-g", LISPNUMBER_VAL(atom));
	    break;

	case ATOM_STRING:
            printf ("\"%s\"", (char *) LISPATOM_STRINGP(atom));
	    break;

	case ATOM_FUNCTION:
            name = LISPATOM_NAME(atom);
            if (name == NULL) {
	        printf ("#<FUNCTION>(");
	        lispprint_indent (LISPATOM_VALUE(atom), indent, TRUE, "");
            } else
                printf (name);
	    break;

	case ATOM_MACRO:
            name = LISPATOM_NAME(atom);
            if (name == NULL) {
	        printf ("#<user-defined macro>");
	        lispprint_r (LISPATOM_VALUE(atom));
            } else
                printf (name);
	    break;

	case ATOM_USERSPECIAL:
            name = LISPATOM_NAME(atom);
            if (name == NULL) {
	        printf ("#<user-defined special form>");
	        lispprint_r (LISPATOM_VALUE(atom));
            } else
                printf (name);
	    break;

	case ATOM_EXPR:
	    lispprint_r (atom);
	    break;

        case ATOM_ARRAY:
	    lispprint_array (atom);
	    break;

	default:
	    lisperror_internal (lispptr_invalid,
                                "#<unknown atom %d (type %d index %d)>",
                                atom, LISPPTR_TYPE(atom), LISPPTR_INDEX(atom));
    }
    LISPPRINT_HLCLOSE(atom);
}

void
lispprint_indent (lispptr p, unsigned indent, bool nobracket, char *prepend)
{
    lispptr   car;
    lispptr   cdr;
    int       postatom = 0;
    unsigned  i;

    if (LISPPTR_IS_EXPR(p) == FALSE) {
	lispprint_atom (p, indent);
	return;
    }

    if (LISPPRINT_GET_MARK_CONS(p)) {
        printf ("*");
	return;
    } else
        LISPPRINT_MARK_CONS(p);

    if (_CAR(p) == p) {
	printf ("cons self-referenced in car");
        _CAR(p) = lispptr_nil;
    }
    if (_CDR(p) == p) {
	printf ("cons self-referenced in car");
        _CDR(p) = lispptr_nil;
    }

    car = _CAR(p);
    cdr = _CDR(p);

#if 0
    if (cdr != lispptr_nil) { /* Print name of atomic quote. */
        if (car == lispatom_quote) {
	    lispprint_indent (cdr, indent, TRUE, "'");
	    return;
        }
        if (car == lispatom_backquote) {
	    lispprint_indent (cdr, indent, TRUE, "`");
	    return;
        }
        if (car == lispatom_quasiquote) {
	    lispprint_indent (cdr, indent, TRUE, ",");
	    return;
        }
        if (car == lispatom_quasiquote_splice) {
	    lispprint_indent (cdr, indent, TRUE, ",@");
	    return;
        }
    }
#endif

    /* Indent line. */
    if (indent && !nobracket)
        printnl ();
    if (!nobracket)
        DOTIMES(i, indent)
            printf ("  ");

    if (!nobracket) {
        printf ("%s(", prepend);
	prepend = "";
    }

    while (p != lispptr_nil) {
        car = _CAR(p);
        cdr = _CDR(p);

        LISPPRINT_HLOPEN(p);
        LISPPRINT_HLOPEN(car);

        if (postatom)
	    printf (" ");

	/* Check if we already passed car. */
        if (LISPPTR_IS_EXPR(car) && LISPPRINT_GET_MARK_CONS(car)) {
            printf ("*circular*");
	    goto next;
	}

        /* Print dotted pair. */
        if (cdr != lispptr_nil && LISPPTR_IS_EXPR(cdr) == FALSE) {
	    lispprint_atom (car, indent);
    	    printf (" . ");
	    lispprint_atom (cdr, indent);
            break;
        } else if (LISPPTR_IS_EXPR(car)) {
	    lispprint_indent (car, indent + postatom, FALSE, prepend);
	} else {
            printf (prepend);
            lispprint_atom (car, indent + postatom);
        }

        prepend = "";
        postatom = 1;

next:
        LISPPRINT_HLCLOSE(car);
        LISPPRINT_HLCLOSE(p);
        p = _CDR(p);
	/* Check if we already passed cdr. */
        if (LISPPTR_IS_EXPR(p) && LISPPRINT_GET_MARK_CONS(p)) {
            printf ("*circular");
	    break;
	}
    }

    if (!nobracket)
        printf (")");
}

void
lispprint_r (lispptr p)
{
    lispprint_indent (p, 0, FALSE, "");
    lispprint_no_nl = FALSE;
}

void
lispprint (lispptr p)
{
    lispprint_wipe_marks ();
    lispprint_r (p);
    printnl ();
}
