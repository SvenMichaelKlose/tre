/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Array-related section.
 */

#ifndef LISP_BUILTIN_ARRAY_H
#define LISP_BUILTIN_ARRAY_H

extern lispptr lisparray_builtin_make (lispptr);
extern lispptr lisparray_builtin_p (lispptr);
extern lispptr lisparray_builtin_aref (lispptr);
extern lispptr lisparray_builtin_set_aref (lispptr);

#endif
