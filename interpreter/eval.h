/*
 * tré – Copyright (c) 2005–2009,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_EVAL_H
#define TRE_EVAL_H

#define TREEVAL_RETURN_JUMP(p) \
        if (eval_is_jump (p)) { return p; }

typedef treptr (*evalfunc_t) (treptr);
typedef double (*eval_opfunc_t) (double, double);

extern treptr eval (treptr);
extern treptr eval_args (treptr p);
extern treptr eval_list (treptr);
extern treptr eval_funcall (treptr func, treptr args, bool evalargs);
extern treptr eval_xlat_function (evalfunc_t *, treptr func, treptr expr, bool do_argeval);

extern void eval_set_stackplace (treptr plc, treptr val);

extern void eval_init (void);

#endif 	/* #ifndef TRE_EVAL_H */

#endif /* #ifdef INTERPRETER */
