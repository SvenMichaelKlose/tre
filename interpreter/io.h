/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Simple streams
 */

#ifndef LISP_IO_H
#define LISP_IO_H

#include <stdio.h>

struct lisp_stream {
    struct lispio_ops  *ops;
    int  putback_char;
    int  last_char;
    void  *detail_in;
    void  *detail_out;
};

struct lispio_ops {
    int (*getc) (void *);
    void (*putc) (void *, char);
    int (*eof) (void *);
    void (*flush) (void *);
    void (*close) (void *);
};

#define LISPIO_OP(s) (s->ops)
#define LISPIO_GETC(s) ((*s->ops->getc) (s->detail_in))
#define LISPIO_PUTC(s, c) ((*s->ops->putc) (s->detail_out, c))
#define LISPIO_EOF(s) ((*s->ops->eof) (s->detail_in))
#define LISPIO_CLOSE(s) ((*s->ops->close) (s->detail_in))
#define LISPIO_FLUSH(s) ((*s->ops->flush) (s->detail_out))

extern struct lisp_stream  *lispio_reader;  /* Reader stream */
extern struct lisp_stream  *lispio_console; /* Console stream */

/* Reader stream diversion stack pointer */
extern unsigned lispio_readerstreamptr;

extern struct lisp_stream *lispio_make_stream (struct lispio_ops *ops);

extern int lispio_getc (struct lisp_stream *);
extern int lispio_getline (struct lisp_stream *,char *s, unsigned maxlen);
extern void lispio_putback (struct lisp_stream *);
extern void lispio_putc (struct lisp_stream *, char);
extern void lispio_flush (struct lisp_stream *);
extern void lispio_skip_spaces (struct lisp_stream *);
extern int lispio_eof (struct lisp_stream *);
extern void lispio_prompt (void);

/* Standard stream diversion for LOAD and related functions. */
extern void lispiostd_divert (struct lisp_stream *);
extern void lispiostd_undivert (void);
extern void lispiostd_undivert_all (void);

extern void lispio_init (void);

#endif
