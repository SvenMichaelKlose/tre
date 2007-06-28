/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Streams
 */

#ifndef LISP_BUILTIN_STREAM_H
#define LISP_BUILTIN_STREAM_H

extern lispptr lispstream_builtin_princ (lispptr);
extern lispptr lispstream_builtin_force_output (lispptr);
extern lispptr lispstream_builtin_read_char (lispptr);
extern lispptr lispstream_builtin_feof (lispptr);

#endif /* #ifndef LISP_BUILTIN_STREAM_H */
