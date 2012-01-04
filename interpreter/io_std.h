/*
 * tré - Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_IO_STD_H
#define TRE_IO_STD_H

extern struct treio_ops treio_ops_std;

struct tre_stream *treiostd_open_file (char *name);
void treiostd_close_file (void *s);

#endif /* #ifndef TRE_IO_STD_H */
