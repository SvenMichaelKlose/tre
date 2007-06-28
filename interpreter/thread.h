/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Thread
 */

#ifndef LISP_THREAD_H
#define LISP_THREAD_H

struct lisp_thread_context {
    lispptr  funstack;
    
    int      token;
    char     token_name[LISP_MAX_SYMLEN + 1];
    char     package_name[LISP_MAX_SYMLEN + 1];

    lispptr  package;
    lispptr  env_current;
};

extern struct lisp_thread_context lisp_context;

#define LISPCONTEXT_FUNSTACK()		(lisp_context.funstack)

#define LISPCONTEXT_TOKEN()		(lisp_context.token)
#define LISPCONTEXT_TOKEN_NAME()	(lisp_context.token_name)
#define LISPCONTEXT_PACKAGE()		(lisp_context.package)
#define LISPCONTEXT_PACKAGE_NAME()	(lisp_context.package_name)

#define LISPCONTEXT_ENV_CURRENT()	(lisp_context.env_current)

#define LISPCONTEXT_PARENT()		(CADR(LISPCONTEXT_FUNSTACK()))
#define LISPCONTEXT_CURRENT()		(CAR(LISPCONTEXT_FUNSTACK()))

extern void lispthread_make (void);

extern void lispthread_push_call (lispptr list);
extern void lispthread_pop_call (void);

#endif	/* #ifndef LISP_THREAD_H */
