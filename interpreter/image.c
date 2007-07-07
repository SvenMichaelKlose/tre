/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2007 Sven Klose <pixel@copei.de>
 *
 * Images
 */

#include "lisp.h"
#include "atom.h"
#include "number.h"
#include "list.h"
#include "sequence.h"
#include "string.h"
#include "eval.h"
#include "error.h"
#include "array.h"
#include "diag.h"
#include "gc.h"
#include "util.h"
#include "builtin.h"
#include "special.h"
#include "env.h"
#include "io.h"
#include "main.h"
#include "symbol.h"
#include "print.h"
#include "thread.h"
#include "image.h"

#define _GNU_SOURCE
#include <string.h>
#include <strings.h>
#include <stdlib.h>

#ifdef CRUNSHED
#define LISP_IMAGE_FORMAT_VERSION    -1
#else
#define LISP_IMAGE_FORMAT_VERSION    1
#endif

#define NMARK_SIZE  (NUM_NUMBERS >> 3)

lispptr lispimage_initfun;

struct lispimage_header {
    int       format_version;
    lispptr   init_fun;

    unsigned  len_symbols;
    void      *ofs_symbols;

    unsigned  num_strings;
    unsigned  num_arrays;
};

void
lispimage_write (FILE *f, void *p, unsigned len)
{
   fwrite (p, len, 1, f); 
}

void
lispimage_read (FILE *f, void *p, unsigned len)
{
   fread (p, len, 1, f); 
}

void
lispimage_write_atoms (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    lispimage_write (f, lispgc_atommarks, sizeof lispgc_atommarks);

    DOTIMES(i, sizeof lispgc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(lispgc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                lispimage_write (f, &lisp_atoms[idx], sizeof (struct lisp_atom));
            }

            c <<= 1;
        }
    }
}

void
lispimage_write_conses (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    lispimage_write (f, lispgc_listmarks, sizeof lispgc_listmarks);

    DOTIMES(i, sizeof lispgc_listmarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(lispgc_listmarks[i] & c)) {
                idx = (i << 3) + j;
                lispimage_write (f, &lisp_lists[idx], sizeof (struct lisp_list));
            }

            c <<= 1;
        }
    }
}

void
lispimage_write_numbers (FILE *f, char *nmarks)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    lispimage_write (f, nmarks, NMARK_SIZE);

    DOTIMES(i, NMARK_SIZE) {
        c = 1;
        DOTIMES(j, 8) {
            if (nmarks[i] & c) {
                idx = (i << 3) + j;
                lispimage_write (f, &lisp_numbers[idx], sizeof (struct lisp_number));
            }

            c <<= 1;
        }
    }
}

void
lispimage_write_arrays (FILE *f)
{
    unsigned  i;

    DOTIMES(i, NUM_ATOMS)
        if (lisp_atoms[i].type == ATOM_ARRAY)
            lispimage_write (f, lisp_atoms[i].detail,
                             LISPARRAY_SIZE(i) * sizeof (lispptr));
}

void
lispimage_write_strings (FILE *f, unsigned num)
{
    unsigned  i;
    unsigned  j;
    struct lisp_string *s;
    unsigned  *lens = malloc (sizeof (unsigned) * num);

    /* Make and write length index. */
    j = 0;
    DOTIMES(i, NUM_ATOMS)
        if (lisp_atoms[i].type == ATOM_STRING)
            lens[j++] = LISPATOM_STRING(i)->len;
    lispimage_write (f, lens, sizeof (unsigned) * num);

    /* Write strings. */
    DOTIMES(i, NUM_ATOMS) {
        if (lisp_atoms[i].type != ATOM_STRING)
            continue;
        s = LISPATOM_STRING(i);
        lispimage_write (f, &s->str, s->len);
    }

    free (lens);
}

int
lispimage_create (char *file, lispptr init_fun)
{
    struct lispimage_header  h;
    unsigned n_arr = 0;
    unsigned n_str = 0;
    unsigned i;
    FILE  *f;
    char  nmarks[NMARK_SIZE];

    lispimage_initfun = init_fun;
    lispgc_force ();
    lispsymbol_gc ();
    lispgc_mark_non_internal ();

    /* Count arrays and strings, trace numbers. */
    bzero (nmarks, NMARK_SIZE);
    DOTIMES(i, NUM_ATOMS) {
        switch (lisp_atoms[i].type) {
            case ATOM_ARRAY:
                n_arr++;
                break;

            case ATOM_STRING:
                n_str++;
                break;

            case ATOM_NUMBER:
                LISP_MARK(nmarks, (unsigned) LISPATOM_DETAIL(i));
                break;
        }
    }

    h.format_version = LISP_IMAGE_FORMAT_VERSION;
    h.init_fun = init_fun;

    h.len_symbols = (unsigned) symbol_table_free - (unsigned) symbol_table;
    h.ofs_symbols = symbol_table;

    h.num_strings = n_str;
    h.num_arrays = n_arr;

    f = fopen (file, "w");
    if (f == NULL)
        return -1;

    fprintf (f, LISP_IMAGE_HEADER);
    fputc (255, f); /* Mark header start. */
    lispimage_write (f, &h, sizeof (struct lispimage_header));
    lispimage_write_atoms (f);
    lispimage_write_conses (f);
    lispimage_write_numbers (f, nmarks);
    lispimage_write_arrays (f);
    lispimage_write (f, symbol_table, h.len_symbols);
    lispimage_write_strings (f, n_str);

    fclose (f);
    return 0;
}

void
lispimage_remove_atoms (void)
{
    unsigned  i;

    DOTIMES(i, NUM_ATOMS) {
        switch (lisp_atoms[i].type) {
            case ATOM_ARRAY:
            case ATOM_STRING:
                lispatom_remove (i);
        }
    }
}

void
lispimage_read_atoms (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    lispimage_read (f, lispgc_atommarks, sizeof lispgc_atommarks);

    DOTIMES(i, sizeof lispgc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(lispgc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                lispimage_read (f, &lisp_atoms[idx], sizeof (struct lisp_atom));
            }

            c <<= 1;
        }
    }
}

/* Read conses and link free conses not in image. */
void
lispimage_read_conses (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    unsigned last;
    char c;

    lispimage_read (f, lispgc_listmarks, sizeof lispgc_listmarks);

    lisplist_num_used = 0;
    lisp_lists_free = lispptr_nil;
    last = lispptr_nil;
    DOTIMES(i, sizeof lispgc_listmarks) {
        c = 1;
        DOTIMES(j, 8) {
            idx = (i << 3) + j;
            if (!(lispgc_listmarks[i] & c)) {
                lispimage_read (f, &lisp_lists[idx], sizeof (struct lisp_list));
                lisplist_num_used++;
            } else {
                if (lisp_lists_free == lispptr_nil)
                    lisp_lists_free = idx;
                if (last != lispptr_nil)
                    lisp_lists[last].cdr = idx;
                last = idx;
            }

            c <<= 1;
        }
    }
    lisp_lists[last].cdr = lispptr_nil;
}

/* Make list of free atoms. */
void
lispimage_make_free (void)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    lisp_atoms_free = lispptr_nil;
    DOTIMES(i, sizeof lispgc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (lispgc_atommarks[i] & c) {
                idx = (i << 3) + j;
                lisp_atoms_free = CONS(idx, lisp_atoms_free);
                lisp_atoms[idx].type = ATOM_UNUSED;
            }

            c <<= 1;
        }
    }
}

void
lispimage_read_numbers (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;
    char  nmarks[NMARK_SIZE];

    lispimage_read (f, nmarks, NMARK_SIZE);

    lisp_numbers_free = lispptr_nil;
    DOTIMES(i, NMARK_SIZE) {
        c = 1;
        DOTIMES(j, 8) {
            idx = (i << 3) + j;
            if (nmarks[i] & c) {
                lispimage_read (f, &lisp_numbers[idx], sizeof (struct lisp_number));
            } else
                lisp_numbers_free = CONS(idx, lisp_numbers_free);

            c <<= 1;
        }
    }
}

void
lispimage_read_arrays (FILE *f)
{
    unsigned  i;
    unsigned  l;
    void      *a;

    DOTIMES(i, NUM_ATOMS) {
        if (lisp_atoms[i].type != ATOM_ARRAY)
            continue;

        l = LISPARRAY_SIZE(i) * sizeof (lispptr);
        a = malloc (l);
        lispimage_read (f, a, l);
        LISPATOM_SET_DETAIL(i, a);
    }
}

void
lispimage_read_symbols (FILE *f, struct lispimage_header *h)
{
    unsigned  i;

    bzero (symbol_table, sizeof symbol_table);
    lispimage_read (f, symbol_table, h->len_symbols);

    /* Correct symbol pointers. */
    num_symbols = 0;
    DOTIMES(i, NUM_ATOMS) {
        if (lisp_atoms[i].type == ATOM_UNUSED || lisp_atoms[i].name == NULL)
            continue;

        LISPATOM_NAME(i) = (char *) LISPATOM_NAME(i)
                           - (char *) h->ofs_symbols
                           + (char *) &symbol_table;
        num_symbols++;
    }

    symbol_table_free = &symbol_table[h->len_symbols];
}

void
lispimage_read_strings (FILE *f, struct lispimage_header *h)
{
    struct lisp_string *s;
    unsigned  i;
    unsigned  j;
    unsigned  l;
    unsigned  lenlen = sizeof (unsigned) * h->num_strings;
    unsigned  *lens = malloc (lenlen);

    lispimage_read (f, lens, lenlen);

    j = 0;
    DOTIMES(i, NUM_ATOMS) {
        if (lisp_atoms[i].type != ATOM_STRING)
            continue;

        l = lens[j++];
        s = malloc (l + sizeof (struct lisp_string));
        s->len = l;
        LISPATOM_SET_STRING(i, s);
        lispimage_read (f, &s->str, l);
        (&s->str)[l] = 0;
    }

    free (lens);
}

int
lispimage_load (char *file)
{
    struct lispimage_header  h;
    FILE  *f;

    f = fopen (file, "r");
    if (f == NULL)
        return -1;

    /* Skip over hash bang. */
    while (fgetc (f) != 255)
        if (feof (f))
            goto error;

    lispimage_read (f, &h, sizeof (struct lispimage_header));
    if (h.format_version != LISP_IMAGE_FORMAT_VERSION)
        goto error;

    lispimage_remove_atoms ();

    lispimage_read_atoms (f);
    lispimage_read_conses (f);
    lispimage_make_free ();
    lispimage_read_numbers (f);
    lispimage_read_arrays (f);
    lispimage_read_symbols (f, &h);
    lispimage_read_strings (f, &h);

    lispgc_init ();
    lispthread_make ();
    LISPCONTEXT_FUNSTACK() = lispptr_nil;

    fclose (f);
    lisp_restart (h.init_fun);

error:
    fclose (f);
    return -2;
}

void
lispimage_init ()
{
    lispimage_initfun = lispptr_nil;
}
