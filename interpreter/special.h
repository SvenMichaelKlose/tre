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
extern treevalfunc_t treeval_xlat_spec[];

extern treptr trespecial (treptr func, treptr expr);
extern void trespecial_init (void);

extern treptr function_arguments (treptr);

/* for compiled code */
extern treptr trespecial_apply (treptr);
extern treptr trespecial_apply_compiled (treptr);
extern treptr trespecial_call_compiled (treptr func, treptr args);

extern bool trespecial_is_compiled_funcall (treptr);
extern treptr treeval_compiled_expr (treptr func, treptr expr, treptr argdef, bool do_eval);
extern treptr trespecial_apply_bytecode_call (treptr func, treptr args, bool do_eval);

#endif	/* #ifndef TRE_SPECIAL_H */
