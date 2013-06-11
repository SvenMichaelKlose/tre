/*
 * tré – Copyright (c) 2005–2006,2008–2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_FUNCTION_H
#define TRE_BUILTIN_FUNCTION_H

extern treptr trefunction_native (treptr);
extern treptr trefunction_bytecode (treptr);
extern treptr trefunction_set_bytecode (treptr, treptr);
extern treptr trefunction_source (treptr);
extern treptr trefunction_set_source (treptr, treptr);

extern treptr trefunction_builtin_function_native (treptr);
extern treptr trefunction_builtin_function_bytecode (treptr);
extern treptr trefunction_builtin_usetf_function_bytecode (treptr);
extern treptr trefunction_builtin_function_source (treptr);
extern treptr trefunction_builtin_set_source (treptr);

#endif	/* #ifndef TRE_BUILTIN_FUNCTION_H */
