/*
 * tré – Copyright (c) 2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_EXCEPTION_H
#define TRE_EXCEPTION_H

#include <setjmp.h>

#define TRE_NUM_CATCHERS    16                                                                                                                                

struct _trecatch {
    jmp_buf   jmp;
    treptr *  gc_stack;
    treptr    catcher;
};

typedef struct _trecatch trecatch;

extern trecatch catchers[TRE_NUM_CATCHERS];
extern int current_catcher;

extern void treexception_catch_enter ();
extern void treexception_catch_leave ();
extern void treexception_throw ();

#endif	/* #ifndef TRE_EXCEPTION_H */
