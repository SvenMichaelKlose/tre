/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Top-level.
 */

#ifndef TRE_MAIN_H
#define TRE_MAIN_H

extern treptr treeval_toplevel_current;
extern bool tre_is_initialized;

extern void tre_exit (int);
extern void tre_restart (treptr);
extern treptr tre_main_line (struct tre_stream *);
extern void tre_main (void);

#endif /* #ifndef TRE_MAIN_H */
