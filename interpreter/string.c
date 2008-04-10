/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * String type
 */

#include "config.h"
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
struct tre_string *
trestring_get_raw (unsigned len)
{
    unsigned  l = len + sizeof (struct tre_string);
    struct tre_string *nstr = trealloc (l);

    if (nstr == NULL)
		return nstr;

    nstr->len = len;
    bzero (&nstr->str, len + 1);
    return nstr;
}

void
trestring_copy (char *to, treptr str)
{
    struct tre_string *s = TREATOM_STRING(str);
    strncpy (to, &s->str, s->len + 1);
}

/* Create string atom. */
treptr
trestring_get (const char *str)
{
    struct tre_string *nstr = trestring_get_raw (strlen (str));
    treptr  atom;

    if (nstr == NULL)
        return treerror (treptr_invalid, "out of memory");
    strcpy (&nstr->str, str);
    atom = treatom_alloc (NULL, TRECONTEXT_PACKAGE(), ATOM_STRING, treptr_nil);
    TREATOM_SET_STRING(atom, nstr);
    return atom;
}

/* Remove string. */
void
trestring_free (treptr str)
{
    struct tre_string *s = TREATOM_STRING(str);

    trealloc_free (s);
}

/* Sequence: Get character at index. */
treptr
trestring_t_get (treptr str, unsigned idx)
{
    struct tre_string *s = TREATOM_STRING(str);

    if (s->len < idx) {
        trewarn (TRECONTEXT_CURRENT(), "index out of range");
		return treptr_nil;
    }

    return treatom_number_get ((double) (&s->str)[idx], TRENUMTYPE_CHAR);
}

/* Sequence: replace character at index. */
void
trestring_t_set (treptr str, unsigned idx, treptr val)
{
    struct tre_string *s = TREATOM_STRING(str);

    if (s->len < idx) {
        treerror (TRECONTEXT_CURRENT(), "index out of range");
		return;
    }

    if (TREPTR_IS_NUMBER(val) == FALSE) {
        treerror (val, "can only assign numbers");
        return;
    }

    (&s->str)[idx] = TRENUMBER_VAL(val);
}

/* Sequence: Return length of string. */
unsigned
trestring_t_length (treptr str)
{
    struct tre_string *s = TREATOM_STRING(str);

    return strlen (&s->str);
}

/* Sequence type configuration. */
struct tre_sequence_type trestring_seqtype = {
	trestring_t_set,
	trestring_t_get,
	trestring_t_length
};
