/*
 * tré – Copyright (c) 2005–2008,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

#include "config.h"
#include "atom.h"
#include "stream.h"
#include "stream_string.h"
#include "error.h"
#include "string2.h"
#include "alloc.h"

treioops treio_ops_string;

struct trestream_string_t {
    char * data;
    char * ptr;
};

typedef struct trestream_string_t trestream_string;

void
trestream_string_error (void)
{
    treerror_norecover (treptr_invalid, "Cannot output to string stream.");
}

int
trestream_string_eof (void *s)
{
    trestream_string * d = (trestream_string *) s;

    return !*d->ptr;
}

void
trestream_string_flush (void * s)
{
    (void) s;

    trestream_string_error ();
}

trestream *
trestream_string_make (char * string)
{
    trestream * s = treio_make_stream (&treio_ops_string, "string stream");
    trestream_string * d = malloc (sizeof (trestream_string));

    d->data = string;
    d->ptr = string;
    s->detail_in = d;

    return s;
}

void
trestream_string_close (void * s)
{
    (void) s;
    free (((trestream_string *) s)->data);
    free (s);
}

int
trestream_string_getc (void * s)
{
    trestream_string * d = (trestream_string *) s;

    if (!*d->ptr)
        return 0;
    return *d->ptr++;
}

void
trestream_string_putc (void * s, char c)
{
    (void) s;
    (void) c;

    trestream_string_error ();
}

treioops treio_ops_string = {
    trestream_string_getc,
    trestream_string_putc,
    trestream_string_eof,
    trestream_string_flush,
    trestream_string_close
};
