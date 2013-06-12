/*
 * tré – Copyright (c) 2005–2006,2008–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_ATOM_H
#define TRE_BUILTIN_ATOM_H

extern treptr treatom_symbolp (treptr);
extern treptr treatom_functionp (treptr);
extern treptr treatom_builtinp (treptr);
extern treptr treatom_macrop (treptr);
extern treptr treatom_type_id (treptr);
extern treptr treatom_id (treptr);

extern treptr treatom_builtin_not (treptr);
extern treptr treatom_builtin_eq (treptr);
extern treptr treatom_builtin_eql_binary (treptr, treptr);
extern treptr treatom_builtin_eql (treptr);
extern treptr treatom_builtin_atom (treptr);
extern treptr treatom_builtin_symbolp (treptr);
extern treptr treatom_builtin_functionp (treptr);
extern treptr treatom_builtin_builtinp (treptr);
extern treptr treatom_builtin_macrop (treptr);
extern treptr treatom_builtin_type_id (treptr);
extern treptr treatom_builtin_id (treptr);

#endif	/* #ifndef TRE_BUILTIN_ATOM_H */
