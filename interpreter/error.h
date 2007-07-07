/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Error handling.
 */

#ifndef LISP_ERROR_H
#define LISP_ERROR_H

extern void lisperror_internal (lispptr, const char *msg, ...);
extern lispptr lisperror (lispptr, const char *msg, ...);
extern void lisperror_norecover (lispptr, const char *msg, ...);
extern void lispwarn (lispptr, const char *msg, ...);

extern lispptr lisperror_builtin_error (lispptr);

extern char *lisperror_typestring (lispptr);

#endif	/* #ifndef LISP_ERROR_H */
