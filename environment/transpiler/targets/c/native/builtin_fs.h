/*
 * tré – Copyright (c) 2005–2006,2008,2013–2014 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_BUILTIN_FILEIO_H
#define TRE_BUILTIN_FILEIO_H

extern FILE * tre_fileio_handles[TRE_FILEIO_MAX_FILES];

extern treptr trestream_fopen_wrapper (treptr, treptr);
extern treptr trestream_builtin_fopen (treptr);
extern treptr trestream_builtin_directory (treptr);
extern treptr trestream_builtin_stat (treptr);
extern treptr trestream_builtin_readlink (treptr);
extern long   trestream_fclose (long handle);

#endif	/* #ifndef TRE_BUILTIN_FILEIO_H */
