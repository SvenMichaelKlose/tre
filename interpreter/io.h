/*
 * tré – Copyright (c) 2005–2008,2013 Sven Michael Klose <pixel@copei.de>
 */

#ifndef TRE_IO_H
#define TRE_IO_H

#include <stdio.h>

struct treioops_t {
    int   (*getc) (void *);
    void  (*putc) (void *, char);
    int   (*eof) (void *);
    void  (*flush) (void *);
    void  (*close) (void *);
};

typedef struct treioops_t treioops;

struct trestream_t {
    treioops * ops;
    int        putback_char;
    int        last_char;
    void *     detail_in;
    void *     detail_out;
	char *     file_name;
	size_t     line;
	size_t     column;
};

typedef struct trestream_t trestream;

#define TREIO_OP(s)       (s->ops)
#define TREIO_GETC(s)     ((*s->ops->getc) (s->detail_in))
#define TREIO_PUTC(s, c)  ((*s->ops->putc) (s->detail_out, c))
#define TREIO_EOF(s)      ((*s->ops->eof) (s->detail_in))
#define TREIO_CLOSE(s)    (treio_close_stream (s))
#define TREIO_FLUSH(s)    ((*s->ops->flush) (s->detail_out))

#define ON_STANDARD_STREAM()    (treio_readerstreamptr == 1)

extern trestream * treio_reader;
extern trestream * treio_console;

extern size_t treio_readerstreamptr;

extern trestream * treio_make_stream  (treioops *, const char * name);
extern void        treio_free_stream  (trestream *);
extern void        treio_close_stream (trestream *);

extern int  treio_getc        (trestream *);
extern int  treio_getline     (trestream *, char *s, size_t maxlen);
extern void treio_putback     (trestream *);
extern void treio_putc        (trestream *, char);
extern void treio_flush       (trestream *);
extern void treio_skip_spaces (trestream *);
extern int  treio_eof         (trestream *);
extern void treio_prompt      (void);

extern trestream * treio_get_stream      ();
extern void        treiostd_divert       (trestream *);
extern void        treiostd_undivert     (void);
extern void        treiostd_undivert_all (void);

extern void treio_init (void);

#endif
