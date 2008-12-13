/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
 *
 * UN*X file I/O
 */

#include "config.h"
#include "atom.h"
#include "io.h"
#include "io_std.h"
#include "error.h"
#include "string2.h"
#include "alloc.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <errno.h>

int
treiostd_eof (void *s)
{
    FILE *fd = (FILE *) s;

    return feof (fd);
}

void
treiostd_flush (void * s)
{
    FILE * fd = (FILE *) s;

    fflush (fd);
}

struct tre_stream *
treiostd_open_file (char * name)
{
	const char * txt1 = "file '";
	const char * txt2 = "'";
	char * n = trealloc (strlen (txt1) + strlen (name) + strlen (txt2) + 1);
    struct tre_stream * s;
    FILE * fd;

	/* Assemble file description. */
	stpcpy (stpcpy (stpcpy (n, txt1), name), txt2);

    s = treio_make_stream (&treio_ops_std, n);

    fd = fopen (name, "r");
    if (fd == NULL) {
        fprintf (stderr, "File '%s':\n", name);
		treio_free_stream (s);
		return NULL;
    }

    s->detail_in = fd;
    return s;
}

void
treiostd_close (void * s)
{
    FILE * fd = (FILE *) s;

    clearerr (fd);
    fclose (fd);
}

/* Get character from input stream. */
int
treiostd_getc (void * s)
{
    FILE * fd = (FILE *) s;

    return feof (fd) ? -1 : fgetc (fd);
}

void
treiostd_putc (void * s, char c)
{
    FILE * fd = (FILE *) s;

    fputc (c, fd);
}

struct treio_ops treio_ops_std = {
    treiostd_getc,
    treiostd_putc,
    treiostd_eof,
    treiostd_flush,
    treiostd_close
};
