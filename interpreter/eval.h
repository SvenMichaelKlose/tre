/*
 * tré – Copyright (c) 2005–2009,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_EVAL_H
#define TRE_EVAL_H

#define TREEVAL_RETURN_JUMP(p) \
        if (treeval_is_jump (p)) { return p; }

typedef treptr (*treevalfunc_t) (treptr);
typedef double (*treeval_opfunc_t) (double, double);

extern treptr treeval (treptr);
extern treptr treeval_args (treptr p);
extern treptr treeval_list (treptr);
extern treptr treeval_funcall (treptr fnc, treptr, bool evalargs);
extern treptr treeval_xlat_function (treevalfunc_t *, treptr func, treptr expr, bool do_argeval);

extern void treeval_set_stackplace (treptr plc, treptr val);

extern void treeval_init (void);

#endif 	/* #ifndef TRE_EVAL_H */

#endif /* #ifdef INTERPRETER */
