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

extern struct tre_sequence_type trelist_seqtype;

extern treptr   trelist_copy (treptr);
extern treptr   trelist_copy_tree (treptr);
extern treptr   trelist_delete (tre_size, treptr);
extern long     trelist_position (treptr elt, treptr lst);
extern tre_size trelist_length (treptr);
extern bool     trelist_equal (treptr, treptr);
extern treptr   trelist_nth (treptr, tre_size);
extern treptr   trelist_last (treptr);
extern bool     trelist_check_type (treptr, tre_size atom_type);

#endif 	/* #ifndef TRE_LIST_H */
