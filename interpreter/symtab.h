/*
 * tré – Copyright (c) 2005–2008,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SYMTAB_H
#define TRE_SYMTAB_H

#define TREPTR_SYMBOL(ptr)    ((tresymbol *) TREATOM(ptr))
#define SYMBOL_NAME(ptr)      (TREPTR_SYMBOL(ptr)->name)
#define SYMBOL_VALUE(ptr)     (TREPTR_SYMBOL(ptr)->value)
#define SYMBOL_FUNCTION(ptr)  (TREPTR_SYMBOL(ptr)->function)
#define SYMBOL_PACKAGE(ptr)   (TREPTR_SYMBOL(ptr)->package)

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

extern tresymbol * symtab_add         (treptr atom, char * name, treptr value, treptr fun, treptr package);
extern void        symtab_remove      (treptr atom);
extern treptr      symtab_find        (char * name, treptr atom);
extern void        symtab_set_package (tre_size root_index, treptr package);
extern void        symtab_clear (void);
extern void        symtab_init (void);

#endif
