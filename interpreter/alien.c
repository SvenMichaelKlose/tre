/*
 * tré - Copyright (c) 2005-2008 Sven Klose <pixel@copei.de
 */

#include <dlfcn.h>

#include "config.h"
#include "atom.h"
#include "error.h"
#include "argument.h"
#include "number.h"
#include "alien.h"
#include "list.h"
#include "string2.h"
#include "xxx.h"

treptr
trealien_builtin_dlopen (treptr args)
{
    treptr  path = trearg_get (args);
    void    * hdl;

retry:
    while (TREPTR_IS_STRING(path) == FALSE)
        path = treerror (path, "path to shared object expected");

    hdl = dlopen (TREATOM_STRINGP(path), RTLD_NOW);
    if (hdl == NULL) {
        path = treerror (path, dlerror ());
		goto retry;
	}

    return treatom_number_get ((double) (long) hdl, TRENUMTYPE_INTEGER);
}

treptr
trealien_builtin_dlclose (treptr args)
{
    treptr  hdl = trearg_get (args);
    long    ret;

    while (TREPTR_IS_NUMBER(hdl) == FALSE)
        hdl = treerror (hdl, "number handle expected");

    ret = dlclose ((void *) (long) TRENUMBER_VAL(hdl));
    if (ret == -1)
        return trestring_get (dlerror ());

    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}

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

    ret = dlsym ((void *) (long) TRENUMBER_VAL(hdl), TREATOM_STRINGP(sym));
    if (ret == NULL)
        return trestring_get (dlerror ());

    return treatom_number_get ((double) (long) ret, TRENUMTYPE_INTEGER);
}

treptr
trealien_builtin_call (treptr args)
{
    long    ret;
    treptr  ptr;
    long    (* fun) (void);

    ptr = trearg_get (args);
    while (TREPTR_IS_NUMBER(ptr) == FALSE)
        ptr = treerror (ptr, "number expected");

    fun = (void *) (long) TRENUMBER_VAL(ptr);
    ret = (* fun) ();
    return treatom_number_get ((double) ret, TRENUMTYPE_INTEGER);
}
