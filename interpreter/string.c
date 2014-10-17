/*
 * tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <string.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "error.h"
#include "eval.h"
#include "builtin_sequence.h"
#include "thread.h"
#include "string2.h"
#include "alloc.h"
#include "gc.h"

char *
trestring_get_raw (tre_size len)
{
    tre_size l = len + sizeof (tre_size) + 1;
    char * nstr = malloc (l);

    if (nstr == NULL)
		return nstr;

    TRESTRING_LEN(nstr) = len;
    bzero (TRESTRING_DATA(nstr), len + 1);
    return nstr;
}

void
trestring_copy (char *to, treptr str)
{
    char * s = TREPTR_STRING(str);
    memcpy (to, TRESTRING_DATA(s), TRESTRING_LEN(s) + 1);
}

treptr
trestring_get_binary (const char *str, tre_size len)
{
    char * nstr = trestring_get_raw (len);
    treptr atom;

    if (nstr == NULL)
        return treerror (treptr_invalid, "Out of memory.");

    memcpy (TRESTRING_DATA(nstr), str, len);
    atom = treatom_alloc (TRETYPE_STRING);
    TREATOM(atom) = nstr;

    return atom;
}

treptr
trestring_get (const char *str)
{
    return trestring_get_binary (str, strlen (str));
}

void
trestring_free (treptr str)
{
    free (TREPTR_STRING(str));
}

treptr
trestring_t_get (treptr str, tre_size idx)
{
    char * s = TREPTR_STRING(str);

#ifndef TRE_NO_ASSERTIONS
    if (TRESTRING_LEN(s) < idx)
        treerror_norecover (TRECONTEXT_CURRENT(), "index out of range");
#endif

    return number_get_char ((double) TRESTRING_DATA(s)[idx]);
}

tre_size
trestring_t_length (treptr str)
{
    return TREPTR_STRINGLEN(str);
}

struct tre_sequence_type trestring_seqtype = {
	NULL,
	trestring_t_get,
	trestring_t_length
};
