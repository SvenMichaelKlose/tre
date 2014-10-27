/*
 * tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_LIST_H
#define TRE_LIST_H

#include <stddef.h>

#define TRELIST_PUSH(stack, expr)  stack = CONS(expr, stack);
#define TRELIST_POP(stack)         stack = CDR(stack);

#define TRELIST_DEFREGS() \
	treptr car;	\
	treptr cdr

extern struct tre_sequence_type list_seqtype;

extern treptr   list_copy (treptr);
extern treptr   list_copy_tree (treptr);
extern treptr   list_delete (tre_size, treptr);
extern long     list_position (treptr elt, treptr lst);
extern tre_size list_length (treptr);
extern bool     list_equal (treptr, treptr);
extern treptr   nthcdr (tre_size, treptr);
extern treptr   nth (tre_size, treptr);
extern treptr   last (treptr);
extern treptr   filter (treptr fun, treptr);
extern treptr   mapcar (treptr fun, treptr);
extern bool     list_check_type (treptr, tre_size atom_type);

extern treptr   trelist_nthcdr (treptr index, treptr);
extern treptr   trelist_nth (treptr index, treptr);

#endif 	/* #ifndef TRE_LIST_H */
