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
#include "stream_file.h"
#include "error.h"
#include "string2.h"
#include "thread.h"
#include "list.h"
#include "main.h"
#include "builtin_stream.h"

#define STREAM_OP(s)       (s->ops)
#define STREAM_GETC(s)     ((*s->ops->getc) (s->detail_in))
#define STREAM_PUTC(s, c)  ((*s->ops->putc) (s->detail_out, c))
#define STREAM_EOF(s)      ((*s->ops->eof) (s->detail_in))
#define STREAM_CLOSE(s)    (treio_close_stream (s))
#define STREAM_FLUSH(s)    ((*s->ops->flush) (s->detail_out))

trestream * tre_stream_stack[TRE_MAX_NESTED_FILES];
size_t tre_stream_stack_ptr;

trestream * treio_reader;
trestream * treio_console;

bool
on_standard_stream ()
{
    return tre_stream_stack_ptr == 1;
}

void
treio_flush (trestream * s)
{
    return STREAM_FLUSH(s);
}

bool
treio_eof (trestream * s)
{
    return STREAM_EOF(s);
}

int
tabulate (int column, int width)
{
    return (column - (column - 1) % width) + width + 1;
}

void
treio_track_location (trestream * s, int c)
{
    if (c == 10) {
        s->line++;
        s->column = 1;
    } else if (c == '\t') {
        s->column = tabulate (s->column, TRE_DEFAULT_TABSIZE);
    } else
        s->column++;
}

int
treio_getc (trestream * s)
{
    int c;

    if (s->putback_char != -1) {
        c = s->putback_char;
        s->putback_char = -1;
    } else {
        c = STREAM_GETC(s);
        treio_track_location (s, c);
    }

    s->last_char = c;

    return c;
}

void
treio_putc (trestream * s, char c)
{
    STREAM_PUTC(s, c);
}

void
treio_putback (trestream * s)
{
    s->putback_char = s->last_char;
}

int
treio_getline (trestream * str, char * s, size_t maxlen)
{
    int    c = 0;
    size_t i;

    for (i = 0; i < maxlen && (c = treio_getc (str)) != EOF && c!= '\n'; i++)
        s[i] = c;
    s[i]= 0;

    if (c == EOF && i == 0)
 	    return -1 ;

    return i;
}        

void
treio_skip_spaces (trestream * s)
{
    unsigned char c;

    while ((c = treio_getc (s)) != 0)
		if (c > ' ')
	    	break;

    treio_putback (s);
}

trestream *
treio_make_stream (treioops * ops, const char * name)
{
    trestream * s = malloc (sizeof (trestream));
	char *      n = malloc (strlen (name) + 1);

	strcpy (n, name);

	s->file_name = n;
    s->putback_char = -1;
    s->last_char = -1;
    s->ops = ops;
	s->line = 1;
	s->column = 1;

    return s;
}

void
treio_free_stream (trestream * s)
{
	free (s->file_name);
	free (s);
}

void
treio_close_stream (trestream * s)
{
	(*s->ops->close) (s->detail_in);
	treio_free_stream (s);
}

trestream *
treio_get_stream ()
{
    return tre_stream_stack[tre_stream_stack_ptr - 1];
}

void
treiostd_divert (trestream * s)
{
    if (tre_stream_stack_ptr == TRE_MAX_NESTED_FILES)
		treerror_internal (treptr_nil, "Too many nested files.");

    tre_stream_stack[tre_stream_stack_ptr++] = s;
    treio_reader = s;
}

void
treiostd_undivert ()
{
    trestream *s;

    if (tre_stream_stack_ptr < 2)
        return;	/* Don't close standard output. */

    s = tre_stream_stack[--tre_stream_stack_ptr];
    STREAM_CLOSE(s);
    treio_reader = tre_stream_stack[tre_stream_stack_ptr - 1];
}

void
treiostd_undivert_all ()
{
    while (tre_stream_stack_ptr > 1)
        treiostd_undivert ();
}

void
treio_prompt ()
{
    if (tre_stream_stack_ptr != 1)
        return;

	(void) trestream_builtin_terminal_normal (treptr_nil);
    printf ("* ");
	tre_interrupt_debugger = FALSE;
    STREAM_FLUSH(treio_console);
}

void
trestream_init ()
{
    trestream * s = treio_make_stream (&treio_ops_std, "standard input");

    s->detail_in = stdin;
    s->detail_out = stdout;

    tre_stream_stack[0] = s;
    tre_stream_stack_ptr = 1;
    treio_reader = s;
    treio_console = s;
}
