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

#define TREFUNCTION_INDEX(ptr)              ((size_t) TREATOM_DETAIL(ptr))
#define TREPTR_FUNCTION(ptr)                (&tre_functions[TREFUNCTION_INDEX(ptr)])

#define TREFUNCTION_SOURCE(ptr)             (TREPTR_TO_ATOM(ptr).value)
#define TREFUNCTION_BINDING(ptr)            (TREPTR_TO_ATOM(ptr).binding)
#define TREFUNCTION_BYTECODE(ptr)           (TREPTR_TO_ATOM(ptr).bytecode)
#define TREFUNCTION_NATIVE(ptr)             (TREPTR_TO_ATOM(ptr).compiled_fun)
#define TREFUNCTION_NATIVE_EXPANDER(ptr)    (TREPTR_TO_ATOM(ptr).compiled_expander)

/*
#define TREFUNCTION_SOURCE(ptr)             (TREPTR_FUNCTION(ptr)->source)
#define TREFUNCTION_NATIVE(ptr)             (TREPTR_FUNCTION(ptr)->native)
#define TREFUNCTION_NATIVE_EXPANDER (ptr)   (TREPTR_FUNCTION(ptr)->native)
*/

extern treptr trefunction_make (tre_type, treptr source);
extern void   trefunction_free (treptr);
extern void   trefunction_init ();

#endif /* #ifndef TRE_FUNCTION_H */
