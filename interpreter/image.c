/*
 * tré – Copyright (c) 2007–2009,2011–2014 Sven Michael Klose <pixel@copei.de>
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
#include "stream.h"
#include "main.h"
#include "symtab.h"
#include "print.h"
#include "thread.h"
#include "image.h"
#include "alloc.h"
#include "function.h"
#include "backtrace.h"
#include "symbol.h"

#ifdef TRE_COMPILED_CRUNSHED
#define TRE_IMAGE_FORMAT_VERSION    (TRE_REVISION | (1 << 31))
#else
#define TRE_IMAGE_FORMAT_VERSION    TRE_REVISION
#endif

#define NMARK_SIZE  (NUM_NUMBERS >> 3)

treptr treimage_initfun;
treptr treptr_saved_restart_stack;

struct treimage_header {
    int       format_version;
    treptr    init_fun;
    tre_size  num_strings;
};

void
treimage_save_stack_content ()
{
    tre_size  i;
    tre_size  size = TRESTACK_SIZE - (((long) trestack_ptr - (long) trestack) / sizeof (treptr));
    treptr *  s = trestack_ptr;

    SYMBOL_VALUE(treptr_saved_restart_stack) = treptr_nil;

    DOTIMES(i, size)
        SYMBOL_VALUE(treptr_saved_restart_stack) = CONS(*s++, SYMBOL_VALUE(treptr_saved_restart_stack));
}

void
treimage_write (FILE *f, void *p, tre_size len)
{
   fwrite (p, len, 1, f); 
}

void
treimage_write_atoms (FILE *f)
{
    tre_size  i;
    tre_size  j;
    tre_size  idx;
    tre_size  symlen;
    char      c;

    treimage_write (f, tregc_atommarks, sizeof tregc_atommarks);

    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                idx = (i << 3) + j;
                treimage_write (f, &tre_atom_types[idx], sizeof (tre_type));
                switch (tre_atom_types[idx]) {
                    case TRETYPE_SYMBOL:
				        symlen = strlen (SYMBOL_NAME(idx));
                        treimage_write (f, &symlen, sizeof (tre_size));
                	    treimage_write (f, SYMBOL_NAME(idx), symlen);
                        treimage_write (f, &SYMBOL_PACKAGE(idx), sizeof (treptr));
                        treimage_write (f, &SYMBOL_VALUE(idx), sizeof (treptr));
                        treimage_write (f, &SYMBOL_FUNCTION(idx), sizeof (treptr));
                        break;

                    case TRETYPE_FUNCTION:
                    case TRETYPE_MACRO:
                    case TRETYPE_USERSPECIAL:
                        treimage_write (f, &FUNCTION_NAME(idx), sizeof (treptr));
                        treimage_write (f, &FUNCTION_SOURCE(idx), sizeof (treptr));
                        treimage_write (f, &FUNCTION_BYTECODE(idx), sizeof (treptr));
                        break;

                    case TRETYPE_BUILTIN:
                    case TRETYPE_SPECIAL:
                        treimage_write (f, &ATOM(idx), sizeof (void *));
                        break;
                }
            }

            c <<= 1;
        }
    }
}

void
treimage_write_conses (FILE *f)
{
    tre_size  i;
    tre_size  j;
    tre_size  idx = 0;
    char      c;

    treimage_write (f, tregc_listmarks, sizeof tregc_listmarks);

    DOTIMES(i, sizeof tregc_listmarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_listmarks[i] & c)) {
                treimage_write (f, &tre_lists[idx], sizeof (struct tre_list));
                treimage_write (f, &tre_listprops[idx], sizeof (treptr));
            }

            c <<= 1;
            idx++;
        }
    }
}

void
treimage_write_numbers (FILE * f)
{
    tre_size  i;

    DOTIMES(i, NUM_ATOMS)
        if (tre_atom_types[i] == TRETYPE_NUMBER)
            treimage_write (f, tre_atoms[i], sizeof (trenumber));
}

void
treimage_write_arrays (FILE *f)
{
    tre_size  i;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] == TRETYPE_ARRAY) {
            treimage_write (f, &TREARRAY_SIZES(i), sizeof (treptr));
            treimage_write (f, TREARRAY_VALUES(i), TREARRAY_SIZE(i) * sizeof (treptr));
        }
    }
}

void
treimage_write_strings (FILE *f, tre_size num)
{
    tre_size   i;
    tre_size   j;
    char *     s;
    tre_size * lens = malloc (sizeof (tre_size) * num);

    /* Make and write length index. */
    j = 0;
    DOTIMES(i, NUM_ATOMS)
        if (tre_atom_types[i] == TRETYPE_STRING)
            lens[j++] = TRESTRING_LEN(TREPTR_STRING(i));
    treimage_write (f, lens, sizeof (tre_size) * num);

    /* Write strings. */
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] == TRETYPE_STRING) {
            s = TREPTR_STRING(i);
            treimage_write (f, TRESTRING_DATA(s), TRESTRING_LEN(s));
        }
    }

    free (lens);
}

tre_size
treimage_count_strings (void)
{
    tre_size  i;
    tre_size  n = 0;

    DOTIMES(i, NUM_ATOMS)
         if (tre_atom_types[i] == TRETYPE_STRING)
                n++;
    return n;
}

int
treimage_create (char *file, treptr init_fun)
{
    struct treimage_header h;
    FILE * f;

    treimage_initfun = init_fun;
    treimage_save_stack_content ();
    tregc_force ();

    h.format_version = TRE_IMAGE_FORMAT_VERSION;
    h.init_fun = init_fun;

    h.num_strings = treimage_count_strings ();

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
    treimage_write_strings (f, h.num_strings);
    fclose (f);

    return 0;
}

void
treimage_read (FILE *f, void *p, tre_size len)
{
   int gcc_warns_if_return_value_is_ignored = fread (p, len, 1, f); 
   (void) gcc_warns_if_return_value_is_ignored;
}

void
treimage_read_atoms (FILE *f)
{
    tre_size  i;
    tre_size  j;
    tre_size  idx = 0;
    tre_size  symlen;
    treptr    package;
    treptr    value;
    treptr    fun;
    char      c;
	char      symbol[TRE_MAX_SYMLEN + 1];

    treimage_read (f, tregc_atommarks, sizeof tregc_atommarks);

    tre_atoms_free = NULL;
    DOTIMES(i, sizeof tregc_atommarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_atommarks[i] & c)) {
                treimage_read (f, &tre_atom_types[idx], sizeof (tre_type));
                switch (tre_atom_types[idx]) {
                    case TRETYPE_SYMBOL:
                        treimage_read (f, &symlen, sizeof (tre_size));
					    if (symlen > TRE_MAX_SYMLEN)
						    treerror_internal (treptr_nil, "While reading image: Symbol exceeds max length %d with length of %d.", TRE_MAX_SYMLEN, symlen);
               		    treimage_read (f, symbol, symlen);
					    symbol[symlen] = 0;
                        treimage_read (f, &package, sizeof (treptr));
                        treimage_read (f, &value, sizeof (treptr));
                        treimage_read (f, &fun, sizeof (treptr));
    				    ATOM(idx) = symtab_add (TRETYPE_INDEX_TO_PTR(tre_atom_types[idx], idx), symbol, value, fun, package);
                        break;

                    case TRETYPE_FUNCTION:
                    case TRETYPE_MACRO:
                    case TRETYPE_USERSPECIAL:
                        ATOM(idx) = trefunction_alloc ();
                        treimage_read (f, &FUNCTION_NAME(idx), sizeof (treptr));
                        treimage_read (f, &FUNCTION_SOURCE(idx), sizeof (treptr));
                        treimage_read (f, &FUNCTION_BYTECODE(idx), sizeof (treptr));
                        break;

                    case TRETYPE_BUILTIN:
                    case TRETYPE_SPECIAL:
                        treimage_read (f, &ATOM(idx), sizeof (void *));
                        break;
                }
            } else {
                *(void **) &tre_atoms[idx] = tre_atoms_free;
                tre_atom_types[idx] = TRETYPE_UNUSED;
                tre_atoms_free = &tre_atoms[idx];
            }

            c <<= 1;
            idx++;
        }
    }
}

/* Read conses and link free conses not in image. */
void
treimage_read_conses (FILE * f)
{
    tre_size  i;
    tre_size  j;
    tre_size  idx = 0;
    char      c;

    treimage_read (f, tregc_listmarks, sizeof tregc_listmarks);

    conses_used = 0;
    conses_free = 0;
    DOTIMES(i, sizeof tregc_listmarks) {
        c = 1;
        DOTIMES(j, 8) {
            if (!(tregc_listmarks[i] & c)) {
                treimage_read (f, &tre_lists[idx], sizeof (struct tre_list));
                treimage_read (f, &tre_listprops[idx], sizeof (treptr));
                conses_used++;
            } else {
                _CDR(idx) = conses_free;
                conses_free = idx;
            }

            c <<= 1;
            idx++;
        }
    }
}

void
treimage_read_numbers (FILE *f)
{
    tre_size    i;
    trenumber * n;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_NUMBER)
            continue;
        n = trenumber_alloc (0, 0);
        treimage_read (f, n, sizeof (trenumber));
        ATOM(i) = n;
	}
}

void
treimage_read_arrays (FILE *f)
{
    tre_size  i;
    tre_size  l;
    trearray  * a;
    treptr    sizes;

    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_ARRAY)
            continue;

        treimage_read (f, &sizes, sizeof (treptr));
        l = trearray_get_size (sizes) * sizeof (treptr);
        a = malloc (sizeof (trearray));
        a->sizes = sizes;
        a->values = malloc (l);
        treimage_read (f, a->values, l);
        ATOM(i) = a;
    }
}

void
treimage_read_strings (FILE *f, struct treimage_header *h)
{
    char *     s;
    tre_size   i;
    tre_size   j;
    tre_size   l;
    tre_size   lenlen = sizeof (tre_size) * h->num_strings;
    tre_size * lens = malloc (lenlen);

    treimage_read (f, lens, lenlen);

    j = 0;
    DOTIMES(i, NUM_ATOMS) {
        if (tre_atom_types[i] != TRETYPE_STRING)
            continue;

        l = lens[j++];
        s = malloc (l + 1 + sizeof (tre_size));
        TRESTRING_LEN(s) = l;
        ATOM(i) = s;
        treimage_read (f, TRESTRING_DATA(s), l);
        (TRESTRING_DATA(s))[l] = 0;
    }

    free (lens);
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

	symtab_clear ();
    treimage_read_atoms (f);
    treimage_read_conses (f);
    treimage_read_numbers (f);
    treimage_read_arrays (f);
    treimage_read_strings (f, &h);
    fclose (f);

    tregc_init ();
    trebacktrace_init ();
    trethread_make ();
    TRECONTEXT_FUNSTACK() = treptr_nil;

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

    treptr_saved_restart_stack = symbol_get ("*SAVED-RESTART-STACK*");
    EXPAND_UNIVERSE(treptr_saved_restart_stack);
}
