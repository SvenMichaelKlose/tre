/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Symbol table
 */

#ifndef TRE_SYMBOL_H
#define TRE_SYMBOL_H

extern char symbol_table[TRE_SYMBOL_TABLE_SIZE];
extern char *symbol_table_free;
extern unsigned num_symbols;

extern void tresymbolpage_remove (treptr atom);
extern void tresymbolpage_add (treptr atom);
extern treptr tresymbolpage_find (char * name, treptr atom);
extern void tresymbolpage_set_package (unsigned long root_index, treptr package);

extern char *tresymbol_add (char *);
extern void tresymbol_free (char *);

extern void tresymbol_init (void);

#endif
