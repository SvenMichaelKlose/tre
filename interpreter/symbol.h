/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SYMBOL_H
#define TRE_SYMBOL_H

#define TREPTR_SYMBOL(ptr)      ((struct tresymbol_page *) TREATOM_DETAIL(ptr))
#define TRESYMBOL_NAME(ptr)     (TREPTR_SYMBOL(ptr)->name)
#define TRESYMBOL_VALUE(ptr)    (TREPTR_SYMBOL(ptr)->value)
#define TRESYMBOL_FUN(ptr)      (TREPTR_SYMBOL(ptr)->function)
#define TRESYMBOL_PACKAGE(ptr)  (TREPTR_SYMBOL(ptr)->package)

struct tresymbol_page {
	struct tresymbol_page * entries[256];
	treptr   atom;
	tre_size num_entries;
	char *   name;
    treptr   value;
    treptr   function;
    treptr   package;
};

struct tresymbol_root {
	treptr package;
	struct tresymbol_page * root;
};

extern tre_size num_symbols;

extern void                    tresymbolpage_remove (treptr atom);
extern struct tresymbol_page * tresymbolpage_add (treptr atom, char * name, treptr package);
extern treptr                  tresymbolpage_find (char * name, treptr atom);
extern void                    tresymbolpage_set_package (tre_size root_index, treptr package);

extern char * tresymbol_add (char *);
extern void   tresymbol_free (char *);

extern void   tresymbol_clear (void);
extern void   tresymbol_init (void);

#endif
