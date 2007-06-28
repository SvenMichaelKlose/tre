/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in list functions
 */

#ifndef LISP_BUILTIN_LIST_H
#define LISP_BUILTIN_LIST_H

extern lispptr lisplist_builtin_cons (lispptr);
extern lispptr lisplist_builtin_list (lispptr);
extern lispptr lisplist_builtin_car (lispptr);
extern lispptr lisplist_builtin_cdr (lispptr);
extern lispptr lisplist_builtin_rplaca (lispptr);
extern lispptr lisplist_builtin_rplacd (lispptr);
extern lispptr lisplist_builtin_consp (lispptr);

#endif	/* #ifndef LISP_BUILTIN_LIST_H */
