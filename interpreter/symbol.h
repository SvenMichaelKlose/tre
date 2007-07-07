/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Symbol table
 */

#ifndef LISP_SYMBOL_H
#define LISP_SYMBOL_H

extern char symbol_table[LISP_SYMBOL_TABLE_SIZE];
extern char *symbol_table_free;
extern unsigned num_symbols;

extern void lispsymbol_gc (void);
extern char *lispsymbol_add (char *);
extern void lispsymbol_free (char *);

extern void lispsymbol_init (void);

#endif
