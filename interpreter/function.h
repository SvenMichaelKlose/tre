/*
 * tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_FUNCTION_H
#define TRE_FUNCTION_H

struct tre_function {
    treptr	source;
    treptr	bytecode;
    void *  native;
    void *  native_expander;
};

extern void * tre_functions_free;
extern struct tre_function tre_functions[NUM_FUNCTIONS];

#define TREPTR_FUNCTION(ptr)                ((struct tre_function *) TREATOM_DETAIL(ptr))
#define TREFUNCTION_SOURCE(ptr)             (TREPTR_FUNCTION(ptr)->source)
#define TREFUNCTION_BYTECODE(ptr)           (TREPTR_FUNCTION(ptr)->bytecode)
#define TREFUNCTION_NATIVE(ptr)             (TREPTR_FUNCTION(ptr)->native)
#define TREFUNCTION_NATIVE_EXPANDER(ptr)    (TREPTR_FUNCTION(ptr)->native_expander)

extern treptr trefunction_make (tre_type, treptr source);
extern struct tre_function * trefunction_alloc ();
extern void   trefunction_free (treptr);
extern void   trefunction_init ();

#endif /* #ifndef TRE_FUNCTION_H */
