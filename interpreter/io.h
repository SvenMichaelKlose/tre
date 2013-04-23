/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_IO_H
#define TRE_IO_H

#include <stdio.h>

struct tre_stream {
    struct treio_ops  *ops;
    int    putback_char;
    int    last_char;
    void * detail_in;
    void * detail_out;
	char * file_name;
	size_t line;
	size_t column;
};

struct treio_ops {
    int   (*getc) (void *);
    void  (*putc) (void *, char);
    int   (*eof) (void *);
    void  (*flush) (void *);
    void  (*close) (void *);
};

#define TREIO_OP(s) (s->ops)
#define TREIO_GETC(s) ((*s->ops->getc) (s->detail_in))
#define TREIO_PUTC(s, c) ((*s->ops->putc) (s->detail_out, c))
#define TREIO_EOF(s) ((*s->ops->eof) (s->detail_in))
#define TREIO_CLOSE(s) (treio_close_stream (s))
#define TREIO_FLUSH(s) ((*s->ops->flush) (s->detail_out))

extern struct tre_stream  *treio_reader;
extern struct tre_stream  *treio_console;

extern size_t treio_readerstreamptr;

extern struct tre_stream * treio_make_stream (struct treio_ops *, const char * name);
extern void treio_free_stream (struct tre_stream *);
extern void treio_close_stream (struct tre_stream *);

extern int  treio_getc (struct tre_stream *);
extern int  treio_getline (struct tre_stream *,char *s, size_t maxlen);
extern void treio_putback (struct tre_stream *);
extern void treio_putc (struct tre_stream *, char);
extern void treio_flush (struct tre_stream *);
extern void treio_skip_spaces (struct tre_stream *);
extern int  treio_eof (struct tre_stream *);
extern void treio_prompt (void);

extern struct tre_stream * treio_get_stream ();
extern void treiostd_divert (struct tre_stream *);
extern void treiostd_undivert (void);
extern void treiostd_undivert_all (void);

extern void treio_init (void);

#endif
