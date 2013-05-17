/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SYMBOL_H
#define TRE_SYMBOL_H

#define TRESYMBOL_NAME(ptr)     ((char *) TREPTR_TO_ATOM(ptr).detail)
#define TRESYMBOL_VALUE(ptr)    (TREPTR_TO_ATOM(ptr).value)
#define TRESYMBOL_FUN(ptr)      (TREPTR_TO_ATOM(ptr).fun)
#define TRESYMBOL_PACKAGE(ptr)  (TREPTR_TO_ATOM(ptr).package)

extern size_t num_symbols;

extern void   tresymbolpage_remove (treptr atom);
extern struct tresymbol_page * tresymbolpage_add (treptr atom);
extern treptr tresymbolpage_find (char * name, treptr atom);
extern void   tresymbolpage_set_package (size_t root_index, treptr package);

extern char * tresymbol_add (char *);
extern void   tresymbol_free (char *);

extern void   tresymbol_clear (void);
extern void   tresymbol_init (void);

#endif
