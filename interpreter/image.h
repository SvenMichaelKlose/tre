/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2007 Sven Klose <pixel@copei.de>
 */

#ifndef LISP_IMAGE_H
#define LISP_IMAGE_H

extern lispptr lispimage_initfun;

extern void lispimage_init (void);
extern int lispimage_create (char *, lispptr init_fun);
extern int lispimage_load (char *);

#endif	/* #ifndef LISP_IMAGE_H */
