/*
 * tré – Copyright (c) 2005–2007,2009,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_SPECIAL_H
#define TRE_SPECIAL_H

#ifdef INTERPRETER

extern bool treeval_is_return (treptr);
extern bool treeval_is_go (treptr);
extern bool treeval_is_jump (treptr);

extern treptr tre_atom_evaluated_go;
extern treptr tre_atom_evaluated_return_from;

#endif /* #ifdef INTERPRETER */

extern char *tre_special_names[];
extern treevalfunc_t treeval_xlat_special[];

extern treptr trespecial (treptr func, treptr expr);
extern void trespecial_init (void);

#endif	/* #ifndef TRE_SPECIAL_H */
