/*
 * tré - Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_STREAM_H
#define TRE_STREAM_H

#include <stdio.h>

extern FILE* tre_fileio_handles[TRE_FILEIO_MAX_FILES];

extern long trestream_fopen (treptr path, treptr mode);
extern long trestream_fclose (long handle);

#endif /* #ifndef TRE_STREAM_H */
