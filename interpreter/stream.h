/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Streams
 */

#ifndef LISP_STREAM_H
#define LISP_STREAM_H

#include <stdio.h>

extern FILE* lisp_fileio_handles[LISP_FILEIO_MAX_FILES];

extern int lispstream_fopen (lispptr path, lispptr mode);

#endif /* #ifndef LISP_STREAM_H */
