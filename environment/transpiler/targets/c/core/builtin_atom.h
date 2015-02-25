/*
 * tré – Copyright (c) 2005–2006,2008–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_ATOM_H
#define TRE_BUILTIN_ATOM_H

extern treptr atom_symbolp (treptr);
extern treptr atom_functionp (treptr);
extern treptr atom_builtinp (treptr);
extern treptr atom_macrop (treptr);
extern treptr atom_type_id (treptr);
extern treptr atom_id (treptr);

extern treptr atom_builtin_not (treptr);
extern treptr atom_builtin_eq (treptr);
extern treptr atom_builtin_eql_binary (treptr, treptr);
extern treptr atom_builtin_eql (treptr);
extern treptr atom_builtin_atom (treptr);

#endif	/* #ifndef TRE_BUILTIN_ATOM_H */
