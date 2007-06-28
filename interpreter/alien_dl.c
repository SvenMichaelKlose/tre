/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de
 *
 * Dynamic linker support
 */

#include "lisp.h"
#include "atom.h"
#include "error.h"
#include "argument.h"
#include "number.h"
#include "alien_dl.h"
#include "list.h"
#include "string.h"

#include <dlfcn.h>

/* Open shared object. */
lispptr
lispalien_builtin_dlopen (lispptr args)
{
    lispptr path = lisparg_get (args);
    void *hdl;

    while (LISPPTR_IS_STRING(path) == FALSE)
        path = lisperror (path, "path to shared object expected");

    hdl = dlopen (LISPATOM_STRINGP(path), RTLD_NOW);
    if (hdl == NULL)
        return lisperror (path, dlerror ());
    return lispatom_number_get ((float) (int) hdl, LISPNUMTYPE_INTEGER);
}

/* Close shared object. */
lispptr
lispalien_builtin_dlclose (lispptr args)
{
    lispptr hdl = lisparg_get (args);
    int     ret;

    while (LISPPTR_IS_NUMBER(hdl) == FALSE)
        hdl = lisperror (hdl, "number handle expected");

    ret = dlclose ((void*) (int) LISPNUMBER_VAL(hdl));
    if (ret == -1)
        return lisperror (hdl, dlerror ());
    return lispatom_number_get ((float) ret, LISPNUMTYPE_INTEGER);
}

/* Get pointer to symbol. */
lispptr
lispalien_builtin_dlsym (lispptr args)
{
    lispptr  hdl;
    lispptr  sym;
    void     *ret;

    lisparg_get2 (&hdl, &sym, args);

    while (LISPPTR_IS_NUMBER(hdl) == FALSE)
        hdl = lisperror (hdl, "number handle expected");

    while (LISPPTR_IS_STRING(sym) == FALSE)
        sym = lisperror (sym, "symbol string expected");

    ret = dlsym ((void*) (int) LISPNUMBER_VAL(hdl), LISPATOM_STRINGP(sym));
    if (ret == NULL)
        return lisperror (hdl, dlerror ());
    return lispatom_number_get ((float) (int) ret, LISPNUMTYPE_INTEGER);
}

size_t
lispalien_argconv (lispptr arg)
{
    if (LISPPTR_IS_NUMBER(arg))
        return (size_t) LISPNUMBER_VAL(arg);
    if (LISPPTR_IS_STRING(arg))
        return (size_t) LISPATOM_STRINGP(arg);

    lisperror_norecover (arg, "integer number or string expected");

    /*NOTREACHED*/
    return 0;
}

/* Call C function with 0 arguments. */
lispptr
lispalien_builtin_dlcall0 (lispptr args)
{
    int      ret;
    lispptr  ptr;
    int      (*fun) (void);

    ptr = lisparg_get (args);
    while (LISPPTR_IS_NUMBER(ptr) == FALSE)
        ptr = lisperror (ptr, "number expected");

    fun = (void *) (int) LISPNUMBER_VAL(ptr);
    ret = (*fun) ();
    return lispatom_number_get ((float) ret, LISPNUMTYPE_INTEGER);
}

/* Call C function with 1 arguments. */
lispptr
lispalien_builtin_dlcall1 (lispptr args)
{
    int      ret;
    lispptr  ptr;
    int      (*fun) (int);
    int      a1;

    ptr = CAR(args);
    while (LISPPTR_IS_NUMBER(ptr) == FALSE)
        ptr = lisperror (ptr, "number expected");

    a1 = lispalien_argconv (CADR(args));

    fun = (void *) (int) LISPNUMBER_VAL(ptr);
    ret = (*fun) (a1);
    return lispatom_number_get ((float) ret, LISPNUMTYPE_INTEGER);
}

/* Call C function with 2 arguments. */
lispptr
lispalien_builtin_dlcall2 (lispptr args)
{
    int      ret;
    lispptr  ptr;
    lispptr  a;
    int      (*fun) (int, int);
    int      a1;
    int      a2;

    ptr = CAR(args);
    while (LISPPTR_IS_NUMBER(ptr) == FALSE)
        ptr = lisperror (ptr, "number expected");

    a = CDR(args);
    a1 = lispalien_argconv (CAR(a));
    a = CDR(a);
    a2 = lispalien_argconv (CAR(a));

    fun = (void *) (int) LISPNUMBER_VAL(ptr);
    ret = (*fun) (a1, a2);
    return lispatom_number_get ((float) ret, LISPNUMTYPE_INTEGER);
}

/* Call C function with 3 arguments. */
lispptr
lispalien_builtin_dlcall3 (lispptr args)
{
    int      ret;
    lispptr  ptr;
    lispptr  a;
    int      (*fun) (int, int, int);
    int      a1;
    int      a2;
    int      a3;

    ptr = CAR(args);
    while (LISPPTR_IS_NUMBER(ptr) == FALSE)
        ptr = lisperror (ptr, "number expected");

    a = CDR(args);
    a1 = lispalien_argconv (CAR(a));
    a = CDR(a);
    a2 = lispalien_argconv (CAR(a));
    a = CDR(a);
    a3 = lispalien_argconv (CAR(a));

    fun = (void *) (int) LISPNUMBER_VAL(ptr);
    ret = (*fun) (a1, a2, a3);
    return lispatom_number_get ((float) ret, LISPNUMTYPE_INTEGER);
}

/* Call C function with 4 arguments. */
lispptr
lispalien_builtin_dlcall4 (lispptr args)
{
    int      ret;
    lispptr  ptr;
    lispptr  a;
    int      (*fun) (int, int, int, int);
    int      a1;
    int      a2;
    int      a3;
    int      a4;

    ptr = CAR(args);
    while (LISPPTR_IS_NUMBER(ptr) == FALSE)
        ptr = lisperror (ptr, "number expected");

    a = CDR(args);
    a1 = lispalien_argconv (CAR(a));
    a = CDR(a);
    a2 = lispalien_argconv (CAR(a));
    a = CDR(a);
    a3 = lispalien_argconv (CAR(a));
    a = CDR(a);
    a4 = lispalien_argconv (CAR(a));

    fun = (void *) (int) LISPNUMBER_VAL(ptr);
    ret = (*fun) (a1, a2, a3, a4);
    return lispatom_number_get ((float) ret, LISPNUMTYPE_INTEGER);
}
