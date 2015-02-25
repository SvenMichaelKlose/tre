/*
 * tré – Copyright (c) 2005–2007,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_IO_STD_H
#define TRE_IO_STD_H

extern treioops treio_ops_std;

trestream * treiostd_open_file  (char * name);
void        treiostd_close_file (void * s);

#endif /* #ifndef TRE_IO_STD_H */
