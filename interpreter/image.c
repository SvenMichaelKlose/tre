/*
 * nix operating system project tre interpreter
 * Copyright (c) 2007-2008 Sven Klose <pixel@copei.de>
 *
 * Images
 */

#include "config.h"
#include "atom.h"
#include "number.h"
#include "list.h"
#include "sequence.h"
#include "string2.h"
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
#include "alloc.h"

#include <string.h>
#include <strings.h>
#include <stdlib.h>

#ifdef TRE_COMPILED_CRUNSHED
#define TRE_IMAGE_FORMAT_VERSION    -1
#else
#define TRE_IMAGE_FORMAT_VERSION    1
#endif

#define NMARK_SIZE  (NUM_NUMBERS >> 3)

treptr treimage_initfun;

struct treimage_header {
    int     format_version;
    treptr  init_fun;
    ulong   num_symbols;
    ulong   num_strings;
    ulong   num_arrays;
};

void
treimage_write (FILE *f, void *p, ulong len)
{
   fwrite (p, len, 1, f); 
}

void
treimage_read (FILE *f, void *p, ulong len)
{
   fread (p, len, 1, f); 
}

void
treimage_write_atoms (FILE *f)
{
    ulong i;
    ulong j;
    ulong idx;
    ulong len;
    char c;
	struct tre_atom buf;

    treimage_write (f, tregc_atommarks, sizeof tregc_atommarks);

    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                idx = (i << 3) + j;
				memcpy (&buf, &tre_atoms[idx], sizeof (struct tre_atom));
				if (tre_atoms[idx].name)
				    len = strlen (tre_atoms[idx].name);
				else
					len = -1;
				buf.name = (char *) len;
                treimage_write (f, &buf, sizeof (struct tre_atom));
				if (len != -1 && len != 0)
                	treimage_write (f, tre_atoms[idx].name, len);
            }

            c <<= 1;
        }
    }
}

void
treimage_write_conses (FILE *f)
{
    ulong i;
    ulong j;
    ulong idx;
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
treimage_write_numbers (FILE * f, char * nmarks)
{
    ulong i;
    ulong j;
    ulong idx;
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
    ulong  i;

    DOTIMES(i, NUM_ATOMS)
        if (tre_atoms[i].type == TRETYPE_ARRAY)
            treimage_write (f, tre_atoms[i].detail, TREARRAY_SIZE(i) * sizeof (treptr));
}

void
treimage_write_strings (FILE *f, ulong num)
{
    ulong  i;
    ulong  j;
    struct tre_string *s;
    ulong  *lens = trealloc (sizeof (ulong) * num);

    /* Make and write length index. */
    j = 0;
    DOTIMES(i, NUM_ATOMS)
        if (tre_atoms[i].type == TRETYPE_STRING)
            lens[j++] = TREATOM_STRING(i)->len;
    treimage_write (f, lens, sizeof (ulong) * num);

    /* Write strings. */
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atoms[i].type != TRETYPE_STRING)
            continue;
        s = TREATOM_STRING(i);
        treimage_write (f, &s->str, s->len);
    }

    trealloc_free (lens);
}

int
treimage_create (char *file, treptr init_fun)
{
    struct treimage_header  h;
    ulong n_arr = 0;
    ulong n_str = 0;
    ulong n_sym = 0;
    ulong i;
    FILE  *f;
    char  nmarks[NMARK_SIZE];

    treimage_initfun = init_fun;
    tregc_force ();
    tregc_mark_non_internal ();

    /* Count arrays and strings, trace numbers. */
    bzero (nmarks, NMARK_SIZE);
    DOTIMES(i, NUM_ATOMS) {
		if (tre_atoms[i].name)
			n_sym++;
        switch (tre_atoms[i].type) {
            case TRETYPE_ARRAY:
                n_arr++;
                break;

            case TRETYPE_STRING:
                n_str++;
                break;

            case TRETYPE_NUMBER:
                TRE_MARK(nmarks, (ulong) TREATOM_DETAIL(i));
                break;
        }
    }

    h.format_version = TRE_IMAGE_FORMAT_VERSION;
    h.init_fun = init_fun;

	h.num_symbols = n_sym;
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
    treimage_write_strings (f, n_str);

    fclose (f);
    return 0;
}

void
treimage_remove_atoms (void)
{
    ulong  i;

    DOTIMES(i, NUM_ATOMS) {
        switch (tre_atoms[i].type) {
            case TRETYPE_ARRAY:
            case TRETYPE_STRING:
                treatom_remove (i);
        }
    }

	tresymbol_clear ();
}

void
treimage_read_atoms (FILE *f)
{
    ulong i;
    ulong j;
    ulong idx;
    ulong symlen;
    char c;
	char symbol[TRE_MAX_SYMLEN + 1];
	char * allocated_symbol;

    treimage_read (f, tregc_atommarks, sizeof tregc_atommarks);

    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                treimage_read (f, &tre_atoms[idx], sizeof (struct tre_atom));
				symlen = (ulong) tre_atoms[idx].name;
				if (symlen == -1)
					tre_atoms[idx].name = NULL;
				else {
					if (symlen > TRE_MAX_SYMLEN)
						treerror_internal (treptr_nil, "image read: symbol exceeds max length %d with length of %d", TRE_MAX_SYMLEN, symlen);
					if (symlen != 0)
                		treimage_read (f, symbol, symlen);
					symbol[symlen] = 0;
    				allocated_symbol = tresymbol_add (symbol);
    				TREATOM_NAME(idx) = allocated_symbol;
    				tresymbolpage_add (TRETYPE_INDEX_TO_PTR(tre_atoms[idx].type, idx));
				}
            }

            c <<= 1;
        }
    }
}

/* Read conses and link free conses not in image. */
void
treimage_read_conses (FILE * f)
{
    ulong i;
    ulong j;
    ulong idx;
    ulong last;
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
    ulong i;
    ulong j;
    ulong idx;
    char c;

    tre_atoms_free = NULL;
    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (tregc_atommarks[i] & c) {
                idx = (i << 3) + j;
                *(void ***) &tre_atoms[idx] = tre_atoms_free;
                tre_atoms_free = &tre_atoms[idx];
                tre_atoms[idx].type = TRETYPE_UNUSED;
            }

            c <<= 1;
        }
    }
}

void
treimage_read_numbers (FILE *f)
{
    ulong i;
    ulong j;
    ulong idx;
    char c;
    char  nmarks[NMARK_SIZE];

    treimage_read (f, nmarks, NMARK_SIZE);

    tre_numbers_free = NULL;
    DOTIMES(i, NMARK_SIZE) {
        c = 1;
        DOTIMES(j, 8) {
            idx = (i << 3) + j;
            if (nmarks[i] & c) {
                treimage_read (f, &tre_numbers[idx], sizeof (struct tre_number));
            } else {
				*(void **) &tre_numbers[idx] = tre_numbers_free;
                tre_numbers_free = &tre_numbers[idx];
			}

            c <<= 1;
        }
    }
}

void
treimage_read_arrays (FILE *f)
{
    ulong  i;
    ulong  l;
    void      *a;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atoms[i].type != TRETYPE_ARRAY)
            continue;

        l = TREARRAY_SIZE(i) * sizeof (treptr);
        a = trealloc (l);
        treimage_read (f, a, l);
        TREATOM_SET_DETAIL(i, a);
    }
}

void
treimage_read_strings (FILE *f, struct treimage_header *h)
{
    struct tre_string *s;
    ulong  i;
    ulong  j;
    ulong  l;
    ulong  lenlen = sizeof (ulong) * h->num_strings;
    ulong  *lens = trealloc (lenlen);

    treimage_read (f, lens, lenlen);

    j = 0;
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atoms[i].type != TRETYPE_STRING)
            continue;

        l = lens[j++];
        s = trealloc (l + sizeof (struct tre_string));
        s->len = l;
        TREATOM_SET_STRING(i, s);
        treimage_read (f, &s->str, l);
        (&s->str)[l] = 0;
    }

    trealloc_free (lens);
}

int
treimage_load (char *file)
{
    struct treimage_header  h;
    FILE  * f;

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
    treimage_read_strings (f, &h);

    tregc_init ();
    trethread_make ();
    TRECONTEXT_FUNSTACK() = treptr_nil;

    fclose (f);

	tremain_init_after_image_loaded ();
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
