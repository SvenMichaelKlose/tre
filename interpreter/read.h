/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Reader.
 */

#ifndef LISP_READ_H
#define LISP_READ_H

extern lispptr lispatom_quasiquote;
extern void lispread_init (void);

extern lispptr lispread (struct lisp_stream *s);

#endif
