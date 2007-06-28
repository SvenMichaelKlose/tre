/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * UN*X file I/O
 */

#include "lisp.h"
#include "atom.h"
#include "io.h"
#include "io_std.h"
#include "error.h"
#include "string.h"

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

int
lispiostd_eof (void *s)
{
    FILE *fd = (FILE *) s;

    return feof (fd);
}

void
lispiostd_flush (void *s)
{
    FILE *fd = (FILE *) s;

    fflush (fd);
}

struct lisp_stream *
lispiostd_open_file (char *name)
{
    struct lisp_stream *s = lispio_make_stream (&lispio_ops_std);
    FILE *fd;

    fd = fopen (name, "r");
    if (fd == NULL) {
        fprintf (stderr, "%s\n", name);
	perror ("couldn't open file");
        lisperror_internal (lispptr_invalid, "file error");
    }

    s->detail_in = fd;
    return s;
}

void
lispiostd_close (void *s)
{
    FILE *fd = (FILE *) s;

    clearerr (fd);
    fclose (fd);
}

/* Get character from input stream. */
int
lispiostd_getc (void *s)
{
    FILE *fd = (FILE *) s;

    return feof (fd) ? -1 : fgetc (fd);
}

void
lispiostd_putc (void *s, char c)
{
    FILE *fd = (FILE *) s;

    fputc (c, fd);
}

struct lispio_ops lispio_ops_std = {
    lispiostd_getc,
    lispiostd_putc,
    lispiostd_eof,
    lispiostd_flush,
    lispiostd_close
};
