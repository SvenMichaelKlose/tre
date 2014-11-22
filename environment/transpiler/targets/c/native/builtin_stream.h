/*
 * tré – Copyright (c) 2005–2006,2008,2014 Sven Michael Klose <pixel@hugbox.org>
 */

#ifndef TRE_BUILTIN_STREAM_H
#define TRE_BUILTIN_STREAM_H

extern treptr trestream_builtin_princ (treptr);
extern treptr trestream_builtin_force_output (treptr);
extern treptr trestream_builtin_read_char (treptr);
extern treptr trestream_builtin_file_exists (treptr);
extern treptr trestream_builtin_feof (treptr);
extern treptr trestream_builtin_fclose (treptr);

#endif /* #ifndef TRE_BUILTIN_STREAM_H */
