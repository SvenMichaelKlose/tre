/*
 * TRE interpreter
 * Copyright (c) 2005-2007,2009 Sven Klose <pixel@copei.de>
 *
 * Built-in special forms.
 */

#ifndef TRE_SPECIAL_H
#define TRE_SPECIAL_H

extern bool treeval_is_return (treptr);
extern bool treeval_is_go (treptr);
extern bool treeval_is_jump (treptr);

extern char *tre_special_names[];

extern treptr tre_atom_evaluated_go;
extern treptr tre_atom_evaluated_return_from;

extern treptr trespecial (treptr func, treptr expr);
extern void trespecial_init (void);

/* for compiled code */
extern treptr trespecial_apply_compiled (treptr);

#endif	/* #ifndef TRE_SPECIAL_H */
