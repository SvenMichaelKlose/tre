/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Reader.
 */

#ifndef TRE_READ_H
#define TRE_READ_H

extern void treread_init (void);

extern treptr treread (struct tre_stream *s);

#endif
