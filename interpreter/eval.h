/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Evaluation-related section.
 */

#ifndef LISP_EVAL_H
#define LISP_EVAL_H

#define LISPEVAL_RETURN_JUMP(p) \
        if (lispeval_is_jump (p)) { return p; }

typedef lispptr (*lispevalfunc_t) (lispptr);
typedef float (*lispeval_opfunc_t) (float, float);

extern lispptr lispeval (lispptr);
extern lispptr lispeval_args (lispptr p);
extern lispptr lispeval_list (lispptr);
extern lispptr lispeval_funcall (lispptr fnc, lispptr, bool evalargs);
extern lispptr lispeval_xlat_function (lispevalfunc_t *, lispptr func, lispptr expr, bool do_argeval);

extern void lispeval_set_stackplace (lispptr plc, lispptr val);

extern void lispeval_init (void);

#endif 	/* #ifndef LISP_EVAL_H */
