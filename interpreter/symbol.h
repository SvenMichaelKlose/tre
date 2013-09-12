/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SYMBOL_H
#define TRE_SYMBOL_H

#define TREPTR_SYMBOL(ptr)      ((tresymbol *) TREATOM_DETAIL(ptr))
#define TRESYMBOL_NAME(ptr)     (TREPTR_SYMBOL(ptr)->name)
#define TRESYMBOL_VALUE(ptr)    (TREPTR_SYMBOL(ptr)->value)
#define TRESYMBOL_FUN(ptr)      (TREPTR_SYMBOL(ptr)->function)
#define TRESYMBOL_PACKAGE(ptr)  (TREPTR_SYMBOL(ptr)->package)

struct tresymbol_t {
	struct tresymbol_t * entries[256];
	treptr   atom;
	tre_size num_entries;
	char *   name;
    treptr   value;
    treptr   function;
    treptr   package;
};

typedef struct tresymbol_t tresymbol;

extern tre_size num_symbols;

extern tresymbol * tresymbol_add         (treptr atom, char * name, treptr value, treptr fun, treptr package);
extern void        tresymbol_remove      (treptr atom);
extern treptr      tresymbol_find        (char * name, treptr atom);
extern void        tresymbol_set_package (tre_size root_index, treptr package);
extern void        tresymbol_clear (void);
extern void        tresymbol_init (void);

#endif
