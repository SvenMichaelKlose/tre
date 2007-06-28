/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Standard I/O
 */

#ifndef LISP_IO_STD_H
#define LISP_IO_STD_H

extern struct lispio_ops lispio_ops_std;

struct lisp_stream *lispiostd_open_file (char *name);
void lispiostd_close_file (void *s);

#endif /* #ifndef LISP_IO_STD_H */
