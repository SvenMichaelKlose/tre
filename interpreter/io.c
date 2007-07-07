/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Simple streams
 *
 * These are provide for standard I/O.
 */

#include "lisp.h"
#include "atom.h"
#include "io.h"
#include "io_std.h"
#include "error.h"
#include "string.h"
#include "thread.h"
#include "list.h"

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

struct lisp_stream *lispio_readerstreams[LISP_MAX_NESTED_FILES];
unsigned lispio_readerstreamptr;

struct lisp_stream  *lispio_reader;      /* Reader stream */
struct lisp_stream  *lispio_console;  /* Console stream */

void
lispio_flush (struct lisp_stream *s)
{
    return LISPIO_FLUSH(s);
}

bool
lispio_eof (struct lisp_stream *s)
{
    return LISPIO_EOF(s);
}

/* Get character from input stream. */
int
lispio_getc (struct lisp_stream *s)
{
    int c;

    if (s->putback_char != -1) {
        c = s->putback_char;
        s->putback_char = -1;
    } else {
        c = LISPIO_GETC(s);
#ifdef LISP_READ_ECHO
        putc (c, stdout);
#endif
    }

    if (c == '\t')
	c = ' ';

    s->last_char = c;

    return c;
}

void
lispio_putc (struct lisp_stream *s, char c)
{
    LISPIO_PUTC(s, c);
}

/* Put back last read char to input stream (only one). */
void
lispio_putback (struct lisp_stream *s)
{
#ifdef DIAGNOSTICS
    if (s->putback_char != -1)
	lisperror_internal (lispptr_nil, "lispio: putback twice");
#endif

    s->putback_char = s->last_char;
}

/* Read line from input stream. */
int
lispio_getline (struct lisp_stream *str, char *s, unsigned maxlen)
{
    int       c = 0;
    unsigned  i;

    /* Read line until end of line or file. */
    for (i = 0; i < maxlen && (c = lispio_getc (str)) != EOF && c!= '\n'; i++)
        s[i] = (c == '\t') ? ' ' : c;

    /* Null-terminate line. */
    s[i]= 0;

    /* Issue end of file if line is empty. */
    if (c == EOF && i == 0)
 	return -1 ;

    return i;
}        

/* Skip over whitespaces. */
void
lispio_skip_spaces (struct lisp_stream *s)
{
    char c;

    while ((c = lispio_getc (s)) != 0)
	if (c > ' ' || c == -1)
	    break;

    lispio_putback (s);
}

struct lisp_stream *
lispio_make_stream (struct lispio_ops *ops)
{
    struct lisp_stream *s = malloc (sizeof (struct lisp_stream));

    s->putback_char = -1;
    s->last_char = -1;
    s->ops = ops;

    return s;
}

void
lispio_init ()
{
    struct lisp_stream *s = lispio_make_stream (&lispio_ops_std);

    s->detail_in = stdin;
    s->detail_out = stdout;

    lispio_readerstreams[0] = s;
    lispio_readerstreamptr = 1;
    lispio_reader = s;
    lispio_console = s;
}

void
lispiostd_divert (struct lisp_stream *s)
{
    if (lispio_readerstreamptr == LISP_MAX_NESTED_FILES)
	lisperror_internal (lispptr_nil, "too many nested files");

    lispio_readerstreams[lispio_readerstreamptr++] = s;
    lispio_reader = s;
}

void
lispiostd_undivert ()
{
    struct lisp_stream *s;

    if (lispio_readerstreamptr < 2)
        return;	/* Don't close standard output. */

    s = lispio_readerstreams[--lispio_readerstreamptr];
    LISPIO_CLOSE(s);
    lispio_reader = lispio_readerstreams[lispio_readerstreamptr - 1];
}

void
lispiostd_undivert_all ()
{
    while (lispio_readerstreamptr > 1)
        lispiostd_undivert ();
}

void
lispio_prompt ()
{
    if (lispio_readerstreamptr != 1)
        return;

    printf ("* ");
    LISPIO_FLUSH(lispio_console);
}
