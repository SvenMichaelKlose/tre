/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2008 Sven Klose <pixel@copei.de
 *
 * Dynamic linker support
 */

#include "config.h"
#include "atom.h"
#include "error.h"
#include "argument.h"
#include "number.h"
#include "alien_dl.h"
#include "list.h"
#include "string.h"

#include <dlfcn.h>

/* Open shared object. */
treptr
trealien_builtin_dlopen (treptr args)
{
    treptr  path = trearg_get (args);
    void    * hdl;

    while (TREPTR_IS_STRING(path) == FALSE)
        path = treerror (path, "path to shared object expected");

    hdl = dlopen (TREATOM_STRINGP(path), RTLD_NOW);
    if (hdl == NULL)
        return treerror (path, dlerror ());
    return treatom_number_get ((double) (int) hdl, TRENUMTYPE_INTEGER);
}

/* Close shared object. */
treptr
trealien_builtin_dlclose (treptr args)
{
    treptr  hdl = trearg_get (args);
    int     ret;

    while (TREPTR_IS_NUMBER(hdl) == FALSE)
        hdl = treerror (hdl, "number handle expected");

    ret = dlclose ((void *) (int) TRENUMBER_VAL(hdl));
    if (ret == -1)
        return treerror (hdl, dlerror ());
    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}

/* Get pointer to symbol. */
treptr
trealien_builtin_dlsym (treptr args)
{
    treptr  hdl;
    treptr  sym;
    void    * ret;

    trearg_get2 (&hdl, &sym, args);

    while (TREPTR_IS_NUMBER(hdl) == FALSE)
        hdl = treerror (hdl, "number handle expected");

    while (TREPTR_IS_STRING(sym) == FALSE)
        sym = treerror (sym, "symbol string expected");

    ret = dlsym ((void *) (int) TRENUMBER_VAL(hdl), TREATOM_STRINGP(sym));
    if (ret == NULL)
        return treerror (hdl, dlerror ());
    return treatom_number_get ((double) (int) ret, TRENUMTYPE_INTEGER);
}

size_t
trealien_argconv (treptr arg)
{
    if (TREPTR_IS_NUMBER(arg))
        return (size_t) TRENUMBER_VAL(arg);
    if (TREPTR_IS_STRING(arg))
        return (size_t) TREATOM_STRINGP(arg);

    treerror_norecover (arg, "integer number or string expected");

    /*NOTREACHED*/
    return 0;
}

/* Call C function with 0 arguments. */
treptr
trealien_builtin_call0 (treptr args)
{
    int     ret;
    treptr  ptr;
    int     (* fun) (void);

    ptr = trearg_get (args);
    while (TREPTR_IS_NUMBER(ptr) == FALSE)
        ptr = treerror (ptr, "number expected");

    fun = (void *) (int) TRENUMBER_VAL(ptr);
    ret = (* fun) ();
    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}

/* Call C function with 1 arguments. */
treptr
trealien_builtin_call1 (treptr args)
{
    int     ret;
    treptr  ptr;
    int     (* fun) (int);
    int     a1;

    ptr = CAR(args);
    while (TREPTR_IS_NUMBER(ptr) == FALSE)
        ptr = treerror (ptr, "number expected");

    a1 = trealien_argconv (CADR(args));

    fun = (void *) (int) TRENUMBER_VAL(ptr);
    ret = (* fun) (a1);
    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}

/* Call C function with 2 arguments. */
treptr
trealien_builtin_call2 (treptr args)
{
    int     ret;
    treptr  ptr;
    treptr  a;
    int     (* fun) (int, int);
    int     a1;
    int     a2;

    ptr = CAR(args);
    while (TREPTR_IS_NUMBER(ptr) == FALSE)
        ptr = treerror (ptr, "number expected");

    a = CDR(args);
    a1 = trealien_argconv (CAR(a));
    a = CDR(a);
    a2 = trealien_argconv (CAR(a));

    fun = (void *) (int) TRENUMBER_VAL(ptr);
    ret = (* fun) (a1, a2);
    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}

/* Call C function with 3 arguments. */
treptr
trealien_builtin_call3 (treptr args)
{
    int     ret;
    treptr  ptr;
    treptr  a;
    int     (* fun) (int, int, int);
    int     a1;
    int     a2;
    int     a3;

    ptr = CAR(args);
    while (TREPTR_IS_NUMBER(ptr) == FALSE)
        ptr = treerror (ptr, "number expected");

    a = CDR(args);
    a1 = trealien_argconv (CAR(a));
    a = CDR(a);
    a2 = trealien_argconv (CAR(a));
    a = CDR(a);
    a3 = trealien_argconv (CAR(a));

    fun = (void *) (int) TRENUMBER_VAL(ptr);
    ret = (* fun) (a1, a2, a3);
    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}

/* Call C function with 4 arguments. */
treptr
trealien_builtin_call4 (treptr args)
{
    int     ret;
    treptr  ptr;
    treptr  a;
    int     (* fun) (int, int, int, int);
    int     a1;
    int     a2;
    int     a3;
    int     a4;

    ptr = CAR(args);
    while (TREPTR_IS_NUMBER(ptr) == FALSE)
        ptr = treerror (ptr, "number expected");

    a = CDR(args);
    a1 = trealien_argconv (CAR(a));
    a = CDR(a);
    a2 = trealien_argconv (CAR(a));
    a = CDR(a);
    a3 = trealien_argconv (CAR(a));
    a = CDR(a);
    a4 = trealien_argconv (CAR(a));

    fun = (void *) (int) TRENUMBER_VAL(ptr);
    ret = (* fun) (a1, a2, a3, a4);
    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}
