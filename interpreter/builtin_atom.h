/*
 * tré – Copyright (c) 2005–2006,2008–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_ATOM_H
#define TRE_BUILTIN_ATOM_H

extern treptr treatom_builtin_not (treptr);
extern treptr treatom_builtin_eq (treptr);
extern treptr treatom_eql (treptr, treptr);
extern treptr treatom_builtin_eql (treptr);
extern treptr treatom_builtin_make_symbol (treptr);
extern treptr treatom_builtin_make_package (treptr);
extern treptr treatom_builtin_atom (treptr);
extern treptr treatom_builtin_symbol_value (treptr);
extern treptr treatom_builtin_usetf_symbol_value (treptr);
extern treptr treatom_builtin_setq_atom_value (treptr);
extern treptr treatom_builtin_symbol_function (treptr);
extern treptr treatom_builtin_usetf_symbol_function (treptr);
extern treptr treatom_builtin_symbol_package (treptr);
extern treptr treatom_builtin_symbol_compiled_function (treptr);
extern treptr treatom_builtin_set_symbol_package (treptr);
extern treptr treatom_builtin_set_atom_fun (treptr);
extern treptr treatom_builtin_functionp (treptr);
extern treptr treatom_builtin_builtinp (treptr);
extern treptr treatom_builtin_macrop (treptr);
extern treptr treatom_builtin_atom_list (treptr);
extern treptr treatom_builtin_type_id (treptr);
extern treptr treatom_builtin_id (treptr);

#endif	/* #ifndef TRE_BUILTIN_ATOM_H */
