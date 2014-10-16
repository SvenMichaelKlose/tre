/*
 * tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_FUNCTION_H
#define TRE_FUNCTION_H

struct trefunction_t {
    treptr	name;
    treptr	source;
    treptr	bytecode;
    void *  native;
    void *  native_expander;
};

typedef struct trefunction_t trefunction;

#define TREPTR_FUNCTION(ptr)                ((trefunction *) TREATOM(ptr))
#define FUNCTION_NAME(ptr)               (TREPTR_FUNCTION(ptr)->name)
#define FUNCTION_SOURCE(ptr)             (TREPTR_FUNCTION(ptr)->source)
#define FUNCTION_BYTECODE(ptr)           (TREPTR_FUNCTION(ptr)->bytecode)
#define FUNCTION_NATIVE(ptr)             (TREPTR_FUNCTION(ptr)->native)
#define FUNCTION_NATIVE_EXPANDER(ptr)    (TREPTR_FUNCTION(ptr)->native_expander)

extern treptr        trefunction_make (tre_type, treptr source);
extern trefunction * trefunction_alloc ();
extern void          trefunction_free (treptr);
extern void          trefunction_init ();

#endif /* #ifndef TRE_FUNCTION_H */
