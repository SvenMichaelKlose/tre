/*
 * tré – Copyright (c) 2005–2008 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SYMBOL_H
#define TRE_SYMBOL_H

extern ulong num_symbols;

extern void   tresymbolpage_remove (treptr atom);
extern void   tresymbolpage_add (treptr atom);
extern treptr tresymbolpage_find (char * name, treptr atom);
extern void   tresymbolpage_set_package (ulong root_index, treptr package);

extern char * tresymbol_add (char *);
extern void   tresymbol_free (char *);

extern void   tresymbol_clear (void);
extern void   tresymbol_init (void);

#endif
