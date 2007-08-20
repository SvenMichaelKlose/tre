/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
 *
 * Streams
 */

#ifndef TRE_STREAM_H
#define TRE_STREAM_H

#include <stdio.h>

extern FILE* tre_fileio_handles[TRE_FILEIO_MAX_FILES];

extern int trestream_fopen (treptr path, treptr mode);

#endif /* #ifndef TRE_STREAM_H */
