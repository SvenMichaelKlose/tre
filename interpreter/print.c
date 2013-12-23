/*
 * tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

/*
 * Use _CAR() and _CDR() to enable debug dumps.
 */

#include "config.h"

#ifdef INTERPRETER

#include <stdio.h>
#include <strings.h>

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "print.h"
#include "error.h"
#include "util.h"
#include "eval.h"
#include "io.h"
#include "string2.h"
#include "thread.h"
#include "array.h"
#include "symbol.h"
#include "function.h"

char treprint_marks_cons[NUM_LISTNODES >> 3];
char treprint_marks_atoms[NUM_ATOMS >> 3];

#define TREPRINT_MARK_CONS(i)     TRE_MARK(treprint_marks_cons, i)
#define TREPRINT_GET_MARK_CONS(i) TRE_GETMARK(treprint_marks_cons, i)
#define TREPRINT_MARK_ATOM(i)     TRE_MARK(treprint_marks_atoms, TREPTR_INDEX(i))
#define TREPRINT_GET_MARK_ATOM(i) TRE_GETMARK(treprint_marks_atoms, TREPTR_INDEX(i))

void
treprint_wipe_marks (void)
{
    bzero (treprint_marks_cons, sizeof (treprint_marks_cons));
    bzero (treprint_marks_atoms, sizeof (treprint_marks_atoms));
}

void treprint_indent (treptr p, size_t indent, bool nobracket, char *prepend);

bool treprint_no_nl;

treptr treprint_highlight;

#define TREPRINT_HL(x,txt) \
    if (NOT_NIL(treprint_highlight) && treprint_highlight == x) \
        printf (txt) 

#define TREPRINT_HLOPEN(x) \
    if (NOT_NIL(treprint_highlight) && treprint_highlight == x) \
        printf (" ---> ") 
#define TREPRINT_HLCLOSE(x) \
    if (NOT_NIL(treprint_highlight) && treprint_highlight == x) { \
        printf (" <--- "); \
		treprint_highlight = treptr_nil; \
    }

void treprint_r (treptr);

void
treprint_array (treptr array)
{
    treptr * elts = TREARRAY_VALUES(array);
    size_t   i;

    printf ("#(");

    DOTIMES(i, TREARRAY_SIZE(array)) {
		treprint_no_nl = TRUE;
        if (i)
	    	printf (" ");
        treprint_r (elts[i]);
    }

    printf (")");
}

bool
treprint_chk_atom_mark (treptr atom)
{
    bool mark;

    if (TREPTR_IS_CONS(atom))
    	return FALSE;

    mark = TREPRINT_GET_MARK_ATOM(atom);
    TREPRINT_MARK_ATOM(atom);
    if (! mark)
    	return FALSE;

    switch (TREPTR_TYPE(atom)) {
       	case TRETYPE_FUNCTION:
       	case TRETYPE_MACRO:
       	case TRETYPE_USERSPECIAL:
        case TRETYPE_ARRAY:
            return TRUE;
    }

    return FALSE;
}

void
treprint_atom (treptr atom, size_t indent)
{
    if (treprint_chk_atom_mark (atom)) {
        printf ("unprintable-circularity");
        return;
    }

    TREPRINT_HLOPEN(atom);

    switch (TREPTR_TYPE(atom)) {
		case TRETYPE_SYMBOL:
	    	if (TRESYMBOL_PACKAGE(atom) != TRECONTEXT_PACKAGE())
                printf ("%s:", TRESYMBOL_NAME(TRESYMBOL_PACKAGE(atom)));
           	printf ("%s", TRESYMBOL_NAME(atom));
	    	break;

		case TRETYPE_BUILTIN:
           	printf ("unprintable-builtin");
            break;

		case TRETYPE_SPECIAL:
           	printf ("unprintable-special-form");
            break;

		case TRETYPE_NUMBER:
	    	if (TRENUMBER_TYPE(atom) == TRENUMTYPE_CHAR) {
				printf ("#\\");
	        	putchar ((int) TRENUMBER_VAL(atom));
	    	} else if (TRENUMBER_TYPE(atom) == TRENUMTYPE_INTEGER)
                printf ("%G", TRENUMBER_VAL(atom));
			else if (TRENUMBER_TYPE(atom) == TRENUMTYPE_FLOAT)
                printf ("%.1f", TRENUMBER_VAL(atom));
			else
				treerror_internal (atom, "Unknown number type.");
	    	break;

		case TRETYPE_STRING:
            printf ("\"%s\"", (char *) TREPTR_STRINGZ(atom));
	    	break;

		case TRETYPE_FUNCTION:
	        printf ("#'(");
	        treprint_indent (TREFUNCTION_SOURCE(atom), indent, TRUE, "");
	        printf (")");
	    	break;

		case TRETYPE_MACRO:
	        printf ("(MACRO");
	       	treprint_r (TREFUNCTION_SOURCE(atom));
	       	printf (")");
	    	break;

		case TRETYPE_USERSPECIAL:
	       	printf ("(SPECIAL");
	       	treprint_r (TREFUNCTION_SOURCE(atom));
	       	printf (")");
	    	break;

		case TRETYPE_CONS:
	    	treprint_r (atom);
	    	break;

        case TRETYPE_ARRAY:
	    	treprint_array (atom);
	    	break;

		default:
	    	treerror_internal (treptr_invalid, "#<unknown atom %d (type %d index %d)>", atom, TREPTR_TYPE(atom), TREPTR_INDEX(atom));
    }
    TREPRINT_HLCLOSE(atom);
}

int
treprint_cons (treptr * p, size_t * indent, int * postatom, char ** prepend)
{
    treptr    car;
    treptr    cdr;

	if (NOT(*p))
		return 0;

    car = _CAR(*p);
    cdr = _CDR(*p);

    TREPRINT_HLOPEN(*p);

    if (*postatom)
    	printf (" ");

    if (TREPTR_IS_CONS(car) && TREPRINT_GET_MARK_CONS(car)) {
        printf ("unprintable-circularity");
        return 2;
	}

    if (NOT_NIL(cdr) && TREPTR_IS_ATOM(cdr)) {
    	treprint_atom (car, *indent);
   	    printf (" . ");
    	treprint_atom (cdr, *indent);
		return 0;
    } else if (TREPTR_IS_CONS(car))
    	treprint_indent (car, *indent + *postatom, FALSE, *prepend);
	else {
        printf ("%s", *prepend);
        treprint_atom (car, *indent + *postatom);
    }

    *prepend = "";
    *postatom = 1;

    TREPRINT_HLCLOSE(car);
    TREPRINT_HLCLOSE(*p);
    *p = _CDR(*p);

    if (TREPTR_IS_CONS(*p) && TREPRINT_GET_MARK_CONS(*p)) {
        printf ("unprintable-circularity");
		return 0;
	}

	return 1;
}

void
treprint_indent (treptr p, size_t indent, bool nobracket, char * prepend)
{
    int    postatom = 0;
    size_t i;
	int	   ret;

    if (TREPTR_IS_ATOM(p)) {
		treprint_atom (p, indent);
		return;
    }

    if (TREPRINT_GET_MARK_CONS(p)) {
        printf ("*");
		return;
    } else
        TREPRINT_MARK_CONS(p);

    if (_CAR(p) == p) {
		printf ("cons self-referenced in CAR");
        _CAR(p) = treptr_nil;
    }
    if (_CDR(p) == p) {
		printf ("cons self-referenced in CDR");
        _CDR(p) = treptr_nil;
    }

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

    while (1) {
		ret = treprint_cons (&p, &indent, &postatom, &prepend);
		if (ret == 0)
			break;
		if (ret == 2)
			return;
	}

    if (!nobracket)
        printf (")");
}

void
treprint_r (treptr p)
{
    treprint_indent (p, 0, FALSE, "");
    treprint_no_nl = FALSE;
}

treptr
treprint (treptr p)
{
    treprint_wipe_marks ();
    treprint_r (p);
    printnl ();
	return p;
}

#endif /* #ifdef INTERPRETER */
