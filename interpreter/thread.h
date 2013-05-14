/*
 * tré – Copyright (c) 2005–2007,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_THREAD_H
#define TRE_THREAD_H

struct tre_thread_context {
    treptr  funstack;
    
    int      token;
    char     token_name[TRE_MAX_SYMLEN + 1];
    char     package_name[TRE_MAX_SYMLEN + 1];

    treptr  package;
    treptr  env_current;
};

extern struct tre_thread_context tre_context;

#define TRECONTEXT_FUNSTACK()		(tre_context.funstack)

#define TRECONTEXT_TOKEN()		    (tre_context.token)
#define TRECONTEXT_TOKEN_NAME() 	(tre_context.token_name)
#define TRECONTEXT_PACKAGE()		(tre_context.package)
#define TRECONTEXT_PACKAGE_NAME()	(tre_context.package_name)

#define TRECONTEXT_PARENT()	    	(CADR(TRECONTEXT_FUNSTACK()))
#define TRECONTEXT_CURRENT()		(CAR(TRECONTEXT_FUNSTACK()))

extern void trethread_make (void);
extern void trethread_push_call (treptr list);
extern void trethread_pop_call (void);

#endif	/* #ifndef TRE_THREAD_H */
