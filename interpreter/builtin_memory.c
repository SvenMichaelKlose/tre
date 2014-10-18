/*
 * tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <stdlib.h>
#include <sys/mman.h>

#include "atom.h"
#include "argument.h"
#include "number.h"

treptr
trebuiltin_malloc (treptr args)
{
    treptr  len;
    void    * ret;

    len = trearg_get (args);
	len = trearg_typed (1, TRETYPE_NUMBER, len, "%MALLOC");

	ret = malloc ((size_t) TRENUMBER_VAL(len));

	return number_get_integer ((double) (long) ret);
}

treptr
trebuiltin_malloc_exec (treptr args)
{
    treptr  len;
    void    * ret;

    len = trearg_get (args);
	len = trearg_typed (1, TRETYPE_NUMBER, len, "%MALLOC-EXEC");

	ret = mmap (NULL, (size_t) TRENUMBER_VAL(len),
				PROT_READ | PROT_WRITE | PROT_EXEC,
				MAP_PRIVATE | MAP_ANON,
				-1, 0);

	return number_get_integer ((double) (long) ret);
}

treptr
trebuiltin_free (treptr args)
{
    treptr  ptr;

	ptr = trearg_typed (1, TRETYPE_NUMBER, trearg_get (args), "%FREE");

	free ((void *) (long) TRENUMBER_VAL(ptr));

	return NIL;
}

treptr
trebuiltin_free_exec (treptr args)
{
    treptr  ptr;
    treptr  len;

    trearg_get2 (&ptr, &len, args);
	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%FREE-EXEC");
	len = trearg_typed (1, TRETYPE_NUMBER, len, "%FREE-EXEC");

	munmap ((void *) (long) TRENUMBER_VAL(ptr), (size_t) TRENUMBER_VAL(len));

	return NIL;
}

treptr
trebuiltin_set (treptr args)
{
    treptr  ptr;
    treptr  val;
	char    c;
	char    * p;

    trearg_get2 (&ptr, &val, args);

	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%%SET");
	val = trearg_typed (2, TRETYPE_NUMBER, val, "%%SET");

	c = (char) TRENUMBER_VAL(val);
	p = TRENUMBER_CHARPTR(ptr);
	* p = c;

    return val;
}

treptr
trebuiltin_get (treptr args)
{
    treptr  ptr = trearg_get (args);
	char    * p;

	ptr = trearg_typed (1, TRETYPE_NUMBER, ptr, "%%GET");

	p = TRENUMBER_CHARPTR(ptr);

	return number_get_float ((double) * p);
}
