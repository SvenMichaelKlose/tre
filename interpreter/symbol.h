/*
 * tré – Copyright (c) 2005-2007,2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SYMBOL_H
#define TRE_SYMBOL_H

extern treptr treptr_universe;
extern treptr tre_package_keyword;

#define EXPAND_UNIVERSE(ptr) \
    (TRESYMBOL_VALUE(treptr_universe) = CONS(ptr, TRESYMBOL_VALUE(treptr_universe)))

#define MAKE_HOOK_SYMBOL(var, symbol_name) \
    var = symbol_alloc (symbol_name, TRECONTEXT_PACKAGE(), treptr_nil); \
    EXPAND_UNIVERSE(var)

#define MAKE_SYMBOL(symbol_name, init) \
    if (symtab_find (symbol_name, TRECONTEXT_PACKAGE()) == treptr_invalid) { \
        EXPAND_UNIVERSE(symbol_alloc (symbol_name, TRECONTEXT_PACKAGE(), init)); \
    } else { \
        TRESYMBOL_VALUE(symbol_get (symbol_name, TRECONTEXT_PACKAGE())) = init; \
    }

extern void tresymbol_init (void);

extern treptr symbol_alloc  (char * symbol, treptr package, treptr value);
extern treptr symbol_get    (char *, treptr package);

#endif
