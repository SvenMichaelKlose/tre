/*
 * nix operating system project tre interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Simple streams
 */

#ifndef TRE_IO_H
#define TRE_IO_H

#include <stdio.h>

struct tre_stream {
    struct treio_ops  *ops;
    int  putback_char;
    int  last_char;
    void  *detail_in;
    void  *detail_out;
};

struct treio_ops {
    int (*getc) (void *);
    void (*putc) (void *, char);
    int (*eof) (void *);
    void (*flush) (void *);
    void (*close) (void *);
};

#define TREIO_OP(s) (s->ops)
#define TREIO_GETC(s) ((*s->ops->getc) (s->detail_in))
#define TREIO_PUTC(s, c) ((*s->ops->putc) (s->detail_out, c))
#define TREIO_EOF(s) ((*s->ops->eof) (s->detail_in))
#define TREIO_CLOSE(s) ((*s->ops->close) (s->detail_in))
#define TREIO_FLUSH(s) ((*s->ops->flush) (s->detail_out))

extern struct tre_stream  *treio_reader;  /* Reader stream */
extern struct tre_stream  *treio_console; /* Console stream */

/* Reader stream diversion stack pointer */
extern unsigned treio_readerstreamptr;

extern struct tre_stream *treio_make_stream (struct treio_ops *ops);

extern int treio_getc (struct tre_stream *);
extern int treio_getline (struct tre_stream *,char *s, unsigned maxlen);
extern void treio_putback (struct tre_stream *);
extern void treio_putc (struct tre_stream *, char);
extern void treio_flush (struct tre_stream *);
extern void treio_skip_spaces (struct tre_stream *);
extern int treio_eof (struct tre_stream *);
extern void treio_prompt (void);

/* Standard stream diversion for LOAD and related functions. */
extern void treiostd_divert (struct tre_stream *);
extern void treiostd_undivert (void);
extern void treiostd_undivert_all (void);

extern void treio_init (void);

#endif
