/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * Simple streams
 *
 * These are provide for standard I/O.
 */

#include "config.h"
#include "atom.h"
#include "io.h"
#include "io_std.h"
#include "error.h"
#include "string.h"
#include "thread.h"
#include "list.h"
#include "main.h"
#include "builtin_stream.h"
#include "alloc.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

struct tre_stream * treio_readerstreams[TRE_MAX_NESTED_FILES];
unsigned treio_readerstreamptr;

struct tre_stream  * treio_reader;      /* Reader stream */
struct tre_stream  * treio_console;  /* Console stream */

void
treio_flush (struct tre_stream * s)
{
    return TREIO_FLUSH(s);
}

bool
treio_eof (struct tre_stream * s)
{
    return TREIO_EOF(s);
}

/* Get character from input stream. */
int
treio_getc (struct tre_stream * s)
{
    int c;

    if (s->putback_char != -1) {
        c = s->putback_char;
        s->putback_char = -1;
    } else {
        c = TREIO_GETC(s);
#ifdef TRE_READ_ECHO
        putc (c, stdout);
#endif
		if (c == 10) {
			s->line++;
			s->column = 1;
		} else
			s->column++;
    }

    if (c == '\t')
	c = ' ';

    s->last_char = c;

    return c;
}

void
treio_putc (struct tre_stream * s, char c)
{
    TREIO_PUTC(s, c);
}

/* Put back last read char to input stream (only one). */
void
treio_putback (struct tre_stream * s)
{
#ifdef DIAGNOSTICS
    if (s->putback_char != -1)
	treerror_internal (treptr_nil, "treio: putback twice");
#endif

    s->putback_char = s->last_char;
}

/* Read line from input stream. */
int
treio_getline (struct tre_stream * str, char * s, unsigned maxlen)
{
    int       c = 0;
    unsigned  i;

    /* Read line until end of line or file. */
    for (i = 0; i < maxlen && (c = treio_getc (str)) != EOF && c!= '\n'; i++)
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
treio_skip_spaces (struct tre_stream * s)
{
    char c;

    while ((c = treio_getc (s)) != 0)
	if (c > ' ' || c == -1)
	    break;

    treio_putback (s);
}

struct tre_stream *
treio_make_stream (struct treio_ops * ops, const char * name)
{
    struct tre_stream *s = trealloc (sizeof (struct tre_stream));
	char * n = trealloc (strlen (name) + 1);

	strcpy (n, name);

    s->putback_char = -1;
    s->last_char = -1;
    s->ops = ops;
	s->file_name = n;
	s->line = 1;
	s->column = 1;

    return s;
}

void
treio_free_stream (struct tre_stream * s)
{
	trealloc_free (s->file_name);
	trealloc_free (s);
}

void
treio_close_stream (struct tre_stream * s)
{
	(*s->ops->close) (s->detail_in);
	treio_free_stream (s);
}

void
treio_init ()
{
    struct tre_stream * s = treio_make_stream (&treio_ops_std, "standard input");

    s->detail_in = stdin;
    s->detail_out = stdout;

    treio_readerstreams[0] = s;
    treio_readerstreamptr = 1;
    treio_reader = s;
    treio_console = s;
}

struct tre_stream *
treio_get_stream ()
{
    return treio_readerstreams[treio_readerstreamptr - 1];
}

void
treiostd_divert (struct tre_stream * s)
{
    if (treio_readerstreamptr == TRE_MAX_NESTED_FILES)
		treerror_internal (treptr_nil, "too many nested files");

    treio_readerstreams[treio_readerstreamptr++] = s;
    treio_reader = s;
}

void
treiostd_undivert ()
{
    struct tre_stream *s;

    if (treio_readerstreamptr < 2)
        return;	/* Don't close standard output. */

    s = treio_readerstreams[--treio_readerstreamptr];
    TREIO_CLOSE(s);
    treio_reader = treio_readerstreams[treio_readerstreamptr - 1];
}

void
treiostd_undivert_all ()
{
    while (treio_readerstreamptr > 1)
        treiostd_undivert ();
}

void
treio_prompt ()
{
    if (treio_readerstreamptr != 1)
        return;

	(void) trestream_builtin_terminal_normal (treptr_nil);
    printf ("* ");
	tre_interrupt_debugger = FALSE;
    TREIO_FLUSH(treio_console);
}
