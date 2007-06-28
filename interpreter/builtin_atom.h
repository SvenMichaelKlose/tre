/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Built-in functions
 */

#ifndef LISP_BUILTIN_ATOM_H
#define LISP_BUILTIN_ATOM_H

extern lispptr lispatom_builtin_eq (lispptr);
extern lispptr lispatom_builtin_eql (lispptr);
extern lispptr lispatom_builtin_make_symbol (lispptr);
extern lispptr lispatom_builtin_atom (lispptr);
extern lispptr lispatom_builtin_symbol_value (lispptr);
extern lispptr lispatom_builtin_atom_value (lispptr);
extern lispptr lispatom_builtin_symbol_function (lispptr);
extern lispptr lispatom_builtin_set_atom_fun (lispptr);
extern lispptr lispatom_builtin_mkfunctionatom (lispptr);
extern lispptr lispatom_builtin_functionp (lispptr);
extern lispptr lispatom_builtin_boundp (lispptr);
extern lispptr lispatom_builtin_fboundp (lispptr);
extern lispptr lispatom_builtin_macrop (lispptr);
extern lispptr lispatom_builtin_atom_list (lispptr expr);

#endif	/* #ifndef LISP_BUILTIN_ATOM_H */
