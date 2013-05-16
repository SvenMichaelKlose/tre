/*
 * tré – Copyright (c) 2007–2009,2011–2013 Sven Michael Klose <pixel@copei.de>
 */

#include <string.h>
#include <strings.h>
#include <stdlib.h>

#include "config.h"
#include "atom.h"
#include "cons.h"
#include "list.h"
#include "number.h"
#include "string2.h"
#include "eval.h"
#include "error.h"
#include "array.h"
#include "gc.h"
#include "util.h"
#include "builtin.h"
#include "special.h"
#include "io.h"
#include "main.h"
#include "symbol.h"
#include "print.h"
#include "thread.h"
#include "image.h"
#include "alloc.h"

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
    size_t  num_symbols;
    size_t  num_strings;
    size_t  num_arrays;
};

void
treimage_write (FILE *f, void *p, size_t len)
{
   fwrite (p, len, 1, f); 
}

void
treimage_read (FILE *f, void *p, size_t len)
{
   int gcc_warns_if_return_value_is_ignored = fread (p, len, 1, f); 
   (void) gcc_warns_if_return_value_is_ignored;
}

void
treimage_write_atoms (FILE *f)
{
    size_t   i;
    size_t   j;
    size_t   idx;
    size_t   len;
    char     c;
	struct tre_atom buf;

    treimage_write (f, tregc_atommarks, sizeof tregc_atommarks);

    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                if (1) { /* tre_atom_types[idx] != TRETYPE_NUMBER) { */
				    memcpy (&buf, &tre_atoms[idx], sizeof (struct tre_atom));
				    len = 0;
                    if (tre_atom_types[idx] == TRETYPE_SYMBOL) {
				        len = strlen (tre_atoms[idx].detail);
				        buf.detail = (void *) len;
                    }
                    treimage_write (f, &tre_atom_types[idx], sizeof (tre_type));
                    treimage_write (f, &buf, sizeof (struct tre_atom));
				    if (tre_atom_types[idx] == TRETYPE_SYMBOL)
                	    treimage_write (f, tre_atoms[idx].detail, len);
                }
            }

            c <<= 1;
        }
    }
}

void
treimage_write_conses (FILE *f)
{
    size_t i;
    size_t j;
    size_t idx;
    char   c;

    treimage_write (f, tregc_listmarks, sizeof tregc_listmarks);

    DOTIMES(i, sizeof tregc_listmarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_listmarks[i] & c)) {
                idx = (i << 3) + j;
                treimage_write (f, &tre_lists[idx], sizeof (struct tre_list));
                treimage_write (f, &tre_listprops[idx], sizeof (treptr));
            }

            c <<= 1;
        }
    }
}

void
treimage_write_numbers (FILE * f)
{
    size_t i;

    DOTIMES(i, NUM_ATOMS)
        if (tre_atom_types[i] == TRETYPE_NUMBER)
            treimage_write (f, tre_atoms[i].detail, sizeof (struct tre_number));
}

void
treimage_write_arrays (FILE *f)
{
    size_t i;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_ARRAY)
            continue;

        treimage_write (f, &TREARRAY_SIZES(i), sizeof (treptr));
        treimage_write (f, TREARRAY_VALUES(i), TREARRAY_SIZE(i) * sizeof (treptr));
    }
}

void
treimage_write_strings (FILE *f, size_t num)
{
    size_t   i;
    size_t   j;
    char   * s;
    size_t * lens = trealloc (sizeof (size_t) * num);

    /* Make and write length index. */
    j = 0;
    DOTIMES(i, NUM_ATOMS)
        if (tre_atom_types[i] == TRETYPE_STRING)
            lens[j++] = TRESTRING_LEN(TREPTR_STRING(i));
    treimage_write (f, lens, sizeof (size_t) * num);

    /* Write strings. */
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_STRING)
            continue;
        s = TREPTR_STRING(i);
        treimage_write (f, TRESTRING_DATA(s), TRESTRING_LEN(s));
    }

    trealloc_free (lens);
}

int
treimage_create (char *file, treptr init_fun)
{
    struct treimage_header  h;
    size_t  n_arr = 0;
    size_t  n_str = 0;
    size_t  n_sym = 0;
    size_t  i;
    FILE  * f;

    treimage_initfun = init_fun;
    tregc_force ();
    tregc_mark_non_internal ();

    /* Count arrays and strings. */
    DOTIMES(i, NUM_ATOMS) {
		if (tre_atom_types[i] == TRETYPE_SYMBOL)
			n_sym++;
        switch (tre_atom_types[i]) {
            case TRETYPE_ARRAY:
                n_arr++;
                break;

            case TRETYPE_STRING:
                n_str++;
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
    treimage_write_numbers (f);
    treimage_write_arrays (f);
    treimage_write_strings (f, n_str);

    fclose (f);
    return 0;
}

void
treimage_remove_atoms (void)
{
    size_t i;

    DOTIMES(i, NUM_ATOMS) {
        switch (tre_atom_types[i]) {
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
    size_t i;
    size_t j;
    size_t idx;
    size_t symlen;
    char   c;
	char   symbol[TRE_MAX_SYMLEN + 1];
	char * allocated_symbol;

    treimage_read (f, tregc_atommarks, sizeof tregc_atommarks);

    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                treimage_read (f, &tre_atom_types[idx], sizeof (tre_type));
                if (1) { /* tre_atom_types[idx] != TRETYPE_NUMBER) { */
                    treimage_read (f, &tre_atoms[idx], sizeof (struct tre_atom));
				    if (tre_atom_types[idx] == TRETYPE_SYMBOL) {
				        symlen = (size_t) tre_atoms[idx].detail;
					    if (symlen > TRE_MAX_SYMLEN)
						    treerror_internal (treptr_nil, "image read: symbol exceeds max length %d with length of %d", TRE_MAX_SYMLEN, symlen);
               		    treimage_read (f, symbol, symlen);
					    symbol[symlen] = 0;
    				    allocated_symbol = tresymbol_add (symbol);
    				    ATOM_SET_NAME(idx, allocated_symbol);
    				    tresymbolpage_add (TRETYPE_INDEX_TO_PTR(tre_atom_types[idx], idx));
                    }
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
    size_t i;
    size_t j;
    size_t idx;
    size_t last;
    char   c;

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
                treimage_read (f, &tre_listprops[idx], sizeof (treptr));
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
    size_t i;
    size_t j;
    size_t idx;
    char   c;

    tre_atoms_free = NULL;
    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (tregc_atommarks[i] & c) {
                idx = (i << 3) + j;
                *(void ***) &tre_atoms[idx] = tre_atoms_free;
                tre_atoms_free = &tre_atoms[idx];
                tre_atom_types[idx] = TRETYPE_UNUSED;
            }

            c <<= 1;
        }
    }
}

void
treimage_read_numbers (FILE *f)
{
    size_t i;
    struct tre_number * n;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_NUMBER)
            continue;
        n = trenumber_alloc (0, 0);
        treimage_read (f, n, sizeof (struct tre_number));
        TREATOM_DETAIL(i) = n;
	}
}

void
treimage_read_arrays (FILE *f)
{
    size_t i;
    size_t l;
    struct tre_array * a;
    treptr sizes;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_ARRAY)
            continue;

        treimage_read (f, &sizes, sizeof (treptr));
        l = trearray_get_size (sizes) * sizeof (treptr);
        a = trealloc (sizeof (struct tre_array));
        a->sizes = sizes;
        a->values = trealloc (l);
        treimage_read (f, a->values, l);
        TREATOM_SET_DETAIL(i, a);
    }
}

void
treimage_read_strings (FILE *f, struct treimage_header *h)
{
    char *   s;
    size_t   i;
    size_t   j;
    size_t   l;
    size_t   lenlen = sizeof (size_t) * h->num_strings;
    size_t * lens = trealloc (lenlen);

    treimage_read (f, lens, lenlen);

    j = 0;
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_STRING)
            continue;

        l = lens[j++];
        s = trealloc (l + 1 + sizeof (size_t));
        TRESTRING_LEN(s) = l;
        TREATOM_SET_STRING(i, s);
        treimage_read (f, TRESTRING_DATA(s), l);
        (TRESTRING_DATA(s))[l] = 0;
    }

    trealloc_free (lens);
}

int
treimage_load (char *file)
{
    struct treimage_header  h;
    FILE * f;

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
    return 0;

error:
    fclose (f);
    return -2;
}

void
treimage_init ()
{
    treimage_initfun = treptr_nil;
}
