/*
 * tré – Copyright (c) 2005–2008,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>

#include "config.h"
#include "atom.h"
#include "list.h"
#include "eval.h"
#include "error.h"
#include "number.h"
#include "util.h"
#include "argument.h"
#include "builtin_fs.h"
#include "xxx.h"
#include "string2.h"
#include "queue.h"
#include "assert.h"
#include "gc.h"

FILE * tre_fileio_handles[TRE_FILEIO_MAX_FILES];

long
trestream_fopen (treptr path, treptr mode)
{
    char * spath = TREPTR_STRINGZ(path);
    char * smode = TREPTR_STRINGZ(mode);
    FILE * file  = fopen (spath, smode);
    size_t i;

    if (file == NULL)
        return NIL;

    DOTIMES(i, TRE_FILEIO_MAX_FILES) {
        if (tre_fileio_handles[i] != NULL)
            continue;

        tre_fileio_handles[i] = file;
        break;
    }

    if (i == TRE_FILEIO_MAX_FILES)
        return NIL;

    return i;
}

long
trestream_fclose (long handle)
{
	if (tre_fileio_handles[handle] == NULL || fclose (tre_fileio_handles[handle]))
		return -1;

	tre_fileio_handles[handle] = NULL;
	return 0;
}

treptr
trestream_fopen_wrapper (treptr path, treptr mode)
{
    treptr handle;

	path = trearg_typed (1, TRETYPE_STRING, path, "pathname");
	mode = trearg_typed (2, TRETYPE_STRING, mode, "access mode");

    handle = trestream_fopen (path, mode);
    RETURN_NIL(handle);

    return number_get_integer ((double) handle);
}

treptr
trestream_builtin_fopen (treptr x)
{
    treptr path;
    treptr mode;

    trearg_get2 (&path, &mode, x);
    return trestream_fopen_wrapper (path, mode);
}

treptr
trestream_builtin_directory (treptr x)
{
    treptr path = trearg_get (x);
    treptr l    = tre_make_queue ();
    DIR * d;
    struct dirent * e;
 
    ASSERT_STRING(path);
    if (!(d = opendir (TREPTR_STRINGZ(path))))
        return number_get_integer (errno);
    tregc_push (l);

    while ((e = readdir (d)) != NULL)
        tre_enqueue (l, trestring_get (&e->d_name[0]));

    closedir (d);
    tregc_pop ();
    return tre_queue_list (l);
}

treptr
trestream_builtin_stat (treptr x)
{
    treptr path = trearg_get (x);
    treptr l    = tre_make_queue ();
    struct stat buf;
 
    ASSERT_STRING(path);
    if (stat (TREPTR_STRINGZ(path), &buf))
        return number_get_integer (errno);
    tregc_push (l);

    tre_enqueue (l, number_get_integer (buf.st_dev));
    tre_enqueue (l, number_get_integer (buf.st_ino));
    tre_enqueue (l, number_get_integer (buf.st_mode));
    tre_enqueue (l, number_get_integer (buf.st_nlink));
    tre_enqueue (l, number_get_integer (buf.st_uid));
    tre_enqueue (l, number_get_integer (buf.st_gid));
    tre_enqueue (l, number_get_integer (buf.st_rdev));
    tre_enqueue (l, number_get_integer (buf.st_size));
    tre_enqueue (l, number_get_integer (buf.st_blksize));
    tre_enqueue (l, number_get_integer (buf.st_blocks));
    tre_enqueue (l, number_get_integer (buf.st_atime));
    tre_enqueue (l, number_get_integer (buf.st_mtime));
    tre_enqueue (l, number_get_integer (buf.st_ctime));

    tregc_pop ();
    return tre_queue_list (l);
}

treptr
trestream_builtin_readlink (treptr x)
{
    treptr   path = trearg_get (x);
    char *   buf = malloc (1024);
    ssize_t  len;
    treptr   dest;
 
    ASSERT_STRING(path);
    len = readlink (TREPTR_STRINGZ(path), buf, 1024);
    if (len == -1) {
        free (buf);
        return NIL;
    }

    dest = trestring_get (buf);
    free (buf);
    return dest;
}
