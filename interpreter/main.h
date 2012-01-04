/*
 * tré - Copyright (c) 2005-2010 Sven Klose <pixel@copei.de>
 */

#ifndef TRE_MAIN_H
#define TRE_MAIN_H

extern treptr * trestack;
extern treptr * trestack_top;
extern treptr * trestack_ptr;

extern treptr treeval_toplevel_current;
extern bool tre_is_initialized;
extern bool tre_interrupt_debugger;

extern void tre_exit (int);
extern void tre_restart (treptr);
extern treptr tre_main_line (struct tre_stream *);
extern void tre_main (void);

extern void tremain_init_after_image_loaded (void);

#endif /* #ifndef TRE_MAIN_H */
