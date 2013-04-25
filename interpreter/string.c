/*
 * tré – Copyright (c) 2005–2009,2011–2013 Sven Michael Klose <pixel@copei.de>
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
trestring_get_raw (size_t len)
{
    size_t l = len + sizeof (size_t) + 1;
    char * nstr = trealloc (l);

    if (nstr == NULL)
		return nstr;

    TRESTRING_LEN(nstr) = len;
    bzero (TRESTRING_DATA(nstr), len + 1);
    return nstr;
}

void
trestring_copy (char *to, treptr str)
{
    char * s = TREATOM_STRING(str);
    strncpy (to, TRESTRING_DATA(s), TRESTRING_LEN(s) + 1);
}

treptr
trestring_get (const char *str)
{
    char * nstr = trestring_get_raw (strlen (str));
    treptr atom;

    if (!nstr) {
        tregc_force ();
        nstr = trestring_get_raw (strlen (str));
        if (!nstr)
            return treerror (treptr_invalid, "out of memory");
    }
    strcpy (TRESTRING_DATA(nstr), str);
    atom = treatom_alloc (TRETYPE_STRING);
    TREATOM_SET_STRING(atom, nstr);
    return atom;
}

treptr
trestring_get_binary (const char *str, size_t len)
{
    char * nstr = trestring_get_raw (len);
    treptr atom;

    if (nstr == NULL)
        return treerror (treptr_invalid, "out of memory");
    bcopy (str, TRESTRING_DATA(nstr), len);
    atom = treatom_alloc (TRETYPE_STRING);
    TREATOM_SET_STRING(atom, nstr);
    return atom;
}

void
trestring_free (treptr str)
{
    char * s = TREATOM_STRING(str);

    trealloc_free (s);
}

treptr
trestring_t_get (treptr str, size_t idx)
{
    char * s = TREATOM_STRING(str);

    if (TRESTRING_LEN(s)< idx) {
        trewarn (TRECONTEXT_CURRENT(), "index out of range");
		return treptr_nil;
    }

    return treatom_number_get ((double) TRESTRING_DATA(s)[idx], TRENUMTYPE_CHAR);
}

size_t
trestring_t_length (treptr str)
{
    char * s = TREATOM_STRING(str);

    return TRESTRING_LEN(s);
}

struct tre_sequence_type trestring_seqtype = {
	NULL,
	trestring_t_get,
	trestring_t_length
};
