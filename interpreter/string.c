/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * String type
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "sequence.h"
#include "thread.h"
#include "string.h"
#include "alloc.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>

/* Allocate and initialise string. */
struct lisp_string *
lispstring_get_raw (unsigned len)
{
    unsigned  l = len + sizeof (struct lisp_string);
    struct lisp_string *nstr = lispalloc (l);

    if (nstr == NULL)
	return nstr;

    nstr->len = len;
    bzero (&nstr->str, len + 1);
    return nstr;
}

void
lispstring_copy (char *to, lispptr str)
{
    struct lisp_string *s = LISPATOM_STRING(str);
    strncpy (to, &s->str, s->len + 1);
}

/* Create string atom. */
lispptr
lispstring_get (const char *str)
{
    struct lisp_string *nstr = lispstring_get_raw (strlen (str));
    lispptr  atom;

    if (nstr == NULL)
        return lisperror (lispptr_invalid, "out of memory");
    strcpy (&nstr->str, str);
    atom = lispatom_alloc (NULL, LISPCONTEXT_PACKAGE(), ATOM_STRING, lispptr_nil);
    LISPATOM_SET_STRING(atom, nstr);
    return atom;
}

/* Remove string. */
void
lispstring_free (lispptr str)
{
    struct lisp_string *s = LISPATOM_STRING(str);

    lispalloc_free (s);
}

/* Sequence: Get character at index. */
lispptr
lispstring_t_get (lispptr str, unsigned idx)
{
    struct lisp_string *s = LISPATOM_STRING(str);

    if (s->len < idx) {
        lispwarn (LISPCONTEXT_CURRENT(), "index out of range");
	return lispptr_nil;
    }

    return lispatom_number_get ((float) (&s->str)[idx], LISPNUMTYPE_CHAR);
}

/* Sequence: replace character at index. */
void
lispstring_t_set (lispptr str, unsigned idx, lispptr val)
{
    struct lisp_string *s = LISPATOM_STRING(str);

    if (s->len < idx) {
        lisperror (LISPCONTEXT_CURRENT(), "index out of range");
	return;
    }

    if (LISPPTR_IS_NUMBER(val) == FALSE) {
        lisperror (val, "can only assign numbers");
        return;
    }

    (&s->str)[idx] = LISPNUMBER_VAL(val);
}

/* Sequence: Return length of string. */
unsigned
lispstring_t_length (lispptr str)
{
    struct lisp_string *s = LISPATOM_STRING(str);

    return strlen (&s->str);
}

/* Sequence type configuration. */
struct lisp_sequence_type lispstring_seqtype = {
	lispstring_t_set,
	lispstring_t_get,
	lispstring_t_length
};
