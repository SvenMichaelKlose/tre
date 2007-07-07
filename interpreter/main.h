/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Top-level.
 */

#ifndef LISP_MAIN_H
#define LISP_MAIN_H

extern lispptr lispeval_toplevel_current;
extern bool lisp_is_initialized;

extern void lisp_exit (int);
extern void lisp_restart (lispptr);
extern lispptr lisp_main_line (struct lisp_stream *);
extern void lisp_main (void);

#endif /* #ifndef LISP_MAIN_H */
