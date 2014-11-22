/*
 * tré – Copyright (c) 2005–2008,2013–2014 Sven Michael Klose <pixel@copei.de
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
    while (STRINGP(path) == FALSE)
        path = treerror (path, "Path to shared object expected.");

    hdl = dlopen (TREPTR_STRINGZ(path), RTLD_NOW);
    if (hdl == NULL) {
        path = treerror (path, dlerror ());
		goto retry;
	}

    return number_get ((double) (long) hdl, TRENUMTYPE_INTEGER);
}

treptr
trealien_builtin_dlclose (treptr args)
{
    treptr  hdl = trearg_get (args);
    long    ret;

    while (NUMBERP(hdl) == FALSE)
        hdl = treerror (hdl, "Number handle expected.");

    ret = dlclose ((void *) (long) TRENUMBER_VAL(hdl));
    if (ret == -1)
        return trestring_get (dlerror ());

    return number_get ((double) ret, TRENUMTYPE_INTEGER);
}

treptr
trealien_builtin_dlsym (treptr args)
{
    treptr  hdl;
    treptr  sym;
    void    * ret;

    trearg_get2 (&hdl, &sym, args);

    while (NUMBERP(hdl) == FALSE)
        hdl = treerror (hdl, "Number handle expected.");

    while (STRINGP(sym) == FALSE)
        sym = treerror (sym, "Symbol string expected.");

    ret = dlsym ((void *) (long) TRENUMBER_VAL(hdl), TREPTR_STRINGZ(sym));
    if (ret == NULL)
        return trestring_get (dlerror ());

    return number_get ((double) (long) ret, TRENUMTYPE_INTEGER);
}

treptr
trealien_builtin_call (treptr args)
{
    long    ret;
    treptr  ptr;
    long    (* fun) (void);

    ptr = trearg_get (args);
    while (NUMBERP(ptr) == FALSE)
        ptr = treerror (ptr, "Number expected.");

    fun = (void *) (long) TRENUMBER_VAL(ptr);
    ret = (* fun) ();
    return number_get ((double) ret, TRENUMTYPE_INTEGER);
}
