/*
 * nix operating system project tre interpreter
 * Copyright (c) 2007 Sven Klose <pixel@copei.de>
 *
 * Images
 */

#include "config.h"
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
#define TRE_IMAGE_FORMAT_VERSION    -1
#else
#define TRE_IMAGE_FORMAT_VERSION    1
#endif

#define NMARK_SIZE  (NUM_NUMBERS >> 3)

treptr treimage_initfun;

struct treimage_header {
    int       format_version;
    treptr   init_fun;

    unsigned  len_symbols;
    void      *ofs_symbols;

    unsigned  num_strings;
    unsigned  num_arrays;
};

void
treimage_write (FILE *f, void *p, unsigned len)
{
   fwrite (p, len, 1, f); 
}

void
treimage_read (FILE *f, void *p, unsigned len)
{
   fread (p, len, 1, f); 
}

void
treimage_write_atoms (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    treimage_write (f, tregc_atommarks, sizeof tregc_atommarks);

    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                treimage_write (f, &tre_atoms[idx], sizeof (struct tre_atom));
            }

            c <<= 1;
        }
    }
}

void
treimage_write_conses (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    treimage_write (f, tregc_listmarks, sizeof tregc_listmarks);

    DOTIMES(i, sizeof tregc_listmarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_listmarks[i] & c)) {
                idx = (i << 3) + j;
                treimage_write (f, &tre_lists[idx], sizeof (struct tre_list));
            }

            c <<= 1;
        }
    }
}

void
treimage_write_numbers (FILE *f, char *nmarks)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    treimage_write (f, nmarks, NMARK_SIZE);

    DOTIMES(i, NMARK_SIZE) {
        c = 1;
        DOTIMES(j, 8) {
            if (nmarks[i] & c) {
                idx = (i << 3) + j;
                treimage_write (f, &tre_numbers[idx], sizeof (struct tre_number));
            }

            c <<= 1;
        }
    }
}

void
treimage_write_arrays (FILE *f)
{
    unsigned  i;

    DOTIMES(i, NUM_ATOMS)
        if (tre_atoms[i].type == ATOM_ARRAY)
            treimage_write (f, tre_atoms[i].detail,
                             TREARRAY_SIZE(i) * sizeof (treptr));
}

void
treimage_write_strings (FILE *f, unsigned num)
{
    unsigned  i;
    unsigned  j;
    struct tre_string *s;
    unsigned  *lens = malloc (sizeof (unsigned) * num);

    /* Make and write length index. */
    j = 0;
    DOTIMES(i, NUM_ATOMS)
        if (tre_atoms[i].type == ATOM_STRING)
            lens[j++] = TREATOM_STRING(i)->len;
    treimage_write (f, lens, sizeof (unsigned) * num);

    /* Write strings. */
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atoms[i].type != ATOM_STRING)
            continue;
        s = TREATOM_STRING(i);
        treimage_write (f, &s->str, s->len);
    }

    free (lens);
}

int
treimage_create (char *file, treptr init_fun)
{
    struct treimage_header  h;
    unsigned n_arr = 0;
    unsigned n_str = 0;
    unsigned i;
    FILE  *f;
    char  nmarks[NMARK_SIZE];

    treimage_initfun = init_fun;
    tregc_force ();
    tresymbol_gc ();
    tregc_mark_non_internal ();

    /* Count arrays and strings, trace numbers. */
    bzero (nmarks, NMARK_SIZE);
    DOTIMES(i, NUM_ATOMS) {
        switch (tre_atoms[i].type) {
            case ATOM_ARRAY:
                n_arr++;
                break;

            case ATOM_STRING:
                n_str++;
                break;

            case ATOM_NUMBER:
                TRE_MARK(nmarks, (unsigned) TREATOM_DETAIL(i));
                break;
        }
    }

    h.format_version = TRE_IMAGE_FORMAT_VERSION;
    h.init_fun = init_fun;

    h.len_symbols = (unsigned) symbol_table_free - (unsigned) symbol_table;
    h.ofs_symbols = symbol_table;

    h.num_strings = n_str;
    h.num_arrays = n_arr;

    f = fopen (file, "w");
    if (f == NULL)
        return -1;

    fprintf (f, TRE_IMAGE_HEADER);
    fputc (255, f); /* Mark header start. */
    treimage_write (f, &h, sizeof (struct treimage_header));
    treimage_write_atoms (f);
    treimage_write_conses (f);
    treimage_write_numbers (f, nmarks);
    treimage_write_arrays (f);
    treimage_write (f, symbol_table, h.len_symbols);
    treimage_write_strings (f, n_str);

    fclose (f);
    return 0;
}

void
treimage_remove_atoms (void)
{
    unsigned  i;

    DOTIMES(i, NUM_ATOMS) {
        switch (tre_atoms[i].type) {
            case ATOM_ARRAY:
            case ATOM_STRING:
                treatom_remove (i);
        }
    }
}

void
treimage_read_atoms (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    treimage_read (f, tregc_atommarks, sizeof tregc_atommarks);

    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                treimage_read (f, &tre_atoms[idx], sizeof (struct tre_atom));
            }

            c <<= 1;
        }
    }
}

/* Read conses and link free conses not in image. */
void
treimage_read_conses (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    unsigned last;
    char c;

    treimage_read (f, tregc_listmarks, sizeof tregc_listmarks);

    trelist_num_used = 0;
    tre_lists_free = treptr_nil;
    last = treptr_nil;
    DOTIMES(i, sizeof tregc_listmarks) {
        c = 1;
        DOTIMES(j, 8) {
            idx = (i << 3) + j;
            if (!(tregc_listmarks[i] & c)) {
                treimage_read (f, &tre_lists[idx], sizeof (struct tre_list));
                trelist_num_used++;
            } else {
                if (tre_lists_free == treptr_nil)
                    tre_lists_free = idx;
                if (last != treptr_nil)
                    tre_lists[last].cdr = idx;
                last = idx;
            }

            c <<= 1;
        }
    }
    tre_lists[last].cdr = treptr_nil;
}

/* Make list of free atoms. */
void
treimage_make_free (void)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;

    tre_atoms_free = treptr_nil;
    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (tregc_atommarks[i] & c) {
                idx = (i << 3) + j;
                tre_atoms_free = CONS(idx, tre_atoms_free);
                tre_atoms[idx].type = ATOM_UNUSED;
            }

            c <<= 1;
        }
    }
}

void
treimage_read_numbers (FILE *f)
{
    unsigned i;
    unsigned j;
    unsigned idx;
    char c;
    char  nmarks[NMARK_SIZE];

    treimage_read (f, nmarks, NMARK_SIZE);

    tre_numbers_free = treptr_nil;
    DOTIMES(i, NMARK_SIZE) {
        c = 1;
        DOTIMES(j, 8) {
            idx = (i << 3) + j;
            if (nmarks[i] & c) {
                treimage_read (f, &tre_numbers[idx], sizeof (struct tre_number));
            } else
                tre_numbers_free = CONS(idx, tre_numbers_free);

            c <<= 1;
        }
    }
}

void
treimage_read_arrays (FILE *f)
{
    unsigned  i;
    unsigned  l;
    void      *a;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atoms[i].type != ATOM_ARRAY)
            continue;

        l = TREARRAY_SIZE(i) * sizeof (treptr);
        a = malloc (l);
        treimage_read (f, a, l);
        TREATOM_SET_DETAIL(i, a);
    }
}

void
treimage_read_symbols (FILE *f, struct treimage_header *h)
{
    unsigned  i;

    bzero (symbol_table, sizeof symbol_table);
    treimage_read (f, symbol_table, h->len_symbols);

    /* Correct symbol pointers. */
    num_symbols = 0;
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atoms[i].type == ATOM_UNUSED || tre_atoms[i].name == NULL)
            continue;

        TREATOM_NAME(i) = (char *) TREATOM_NAME(i)
                           - (char *) h->ofs_symbols
                           + (char *) &symbol_table;
        num_symbols++;
    }

    symbol_table_free = &symbol_table[h->len_symbols];
}

void
treimage_read_strings (FILE *f, struct treimage_header *h)
{
    struct tre_string *s;
    unsigned  i;
    unsigned  j;
    unsigned  l;
    unsigned  lenlen = sizeof (unsigned) * h->num_strings;
    unsigned  *lens = malloc (lenlen);

    treimage_read (f, lens, lenlen);

    j = 0;
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atoms[i].type != ATOM_STRING)
            continue;

        l = lens[j++];
        s = malloc (l + sizeof (struct tre_string));
        s->len = l;
        TREATOM_SET_STRING(i, s);
        treimage_read (f, &s->str, l);
        (&s->str)[l] = 0;
    }

    free (lens);
}

int
treimage_load (char *file)
{
    struct treimage_header  h;
    FILE  *f;

    f = fopen (file, "r");
    if (f == NULL)
        return -1;

    /* Skip over hash bang. */
    while (fgetc (f) != 255)
        if (feof (f))
            goto error;

    treimage_read (f, &h, sizeof (struct treimage_header));
    if (h.format_version != TRE_IMAGE_FORMAT_VERSION)
        goto error;

    treimage_remove_atoms ();

    treimage_read_atoms (f);
    treimage_read_conses (f);
    treimage_make_free ();
    treimage_read_numbers (f);
    treimage_read_arrays (f);
    treimage_read_symbols (f, &h);
    treimage_read_strings (f, &h);

    tregc_init ();
    trethread_make ();
    TRECONTEXT_FUNSTACK() = treptr_nil;

    fclose (f);
    tre_restart (h.init_fun);

error:
    fclose (f);
    return -2;
}

void
treimage_init ()
{
    treimage_initfun = treptr_nil;
}
