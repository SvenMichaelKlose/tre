/*
 * TRE interpreter
 * Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>
 *
 * Streams
 */

#ifndef TRE_BUILTIN_STREAM_H
#define TRE_BUILTIN_STREAM_H

extern treptr trestream_builtin_princ (treptr);
extern treptr trestream_builtin_force_output (treptr);
extern treptr trestream_builtin_read_char (treptr);
extern treptr trestream_builtin_feof (treptr);
extern treptr trestream_builtin_fclose (treptr);
extern treptr trestream_builtin_terminal_raw (treptr);
extern treptr trestream_builtin_terminal_normal (treptr);

#endif /* #ifndef TRE_BUILTIN_STREAM_H */
