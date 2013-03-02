/*
 * tré – Copyright (c) 2005–2007,2012 Sven Michael Klose <pixel@copei.de>
 */

#ifdef INTERPRETER

#ifndef TRE_READ_H
#define TRE_READ_H

extern void   treread_init (void);

extern treptr treread (struct tre_stream *s);

#endif /* #ifndef TRE_READ_H */

#endif /* #ifdef INTERPRETER */
