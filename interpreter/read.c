/*
 * nix operating system project lisp interpreter
 * Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
 *
 * Reading LISP expressions.
 */

#include "lisp.h"
#include "atom.h"
#include "list.h"
#include "io.h"
#include "read.h"
#include "error.h"
#include "string.h"
#include "gc.h"
#include "thread.h"
#include "number.h"

#include <ctype.h>
#include <string.h>

/*
 * Token values.
 *
 * Don't forget to update is_symchar().
 */
#define LISPTOKEN_BRACKET_OPEN		1
#define LISPTOKEN_BRACKET_CLOSE		2
#define LISPTOKEN_DOT			3
#define LISPTOKEN_DBLQUOTE		4
#define LISPTOKEN_QUOTE			5
#define LISPTOKEN_BACKQUOTE		6
#define LISPTOKEN_QUASIQUOTE		7
#define LISPTOKEN_QUASIQUOTE_SPLICE	8
#define LISPTOKEN_FUNCTION		9
#define LISPTOKEN_CHAR			10
#define LISPTOKEN_SYMBOL		11	/* Keep this at the end. */

/*
 * Check if the next incoming character would be legal part of a symbol.
 */
bool
is_symchar (char c)
{
    return (c > ' ' && c != '(' && c != ')' && c != '\'' && c != '.'
	    && c != '`' && c != ',' && c != '"' && c != ';' &&c != '#');
}

/*
 * Read symbol.
 *
 * Returns the length of the symbol or 0 if a special character or end
 * of input is read.
 */
int
get_symbol (struct lisp_stream *str, char *s, char *p)
{
    unsigned  len = 0;
    char      *os = s;
    char      c;

    *s = 0;
    *p = -1;
again:
    lispio_skip_spaces (str);

    /* Ignore comments. */
    while (str->last_char == ';') {
        while (lispio_getc (str) >= ' '); /* Read until line end. */
        goto again;
    }

after_pname:
    /* Read until a non-symbol character is found. */
    while (1) {
        c = toupper (lispio_getc (str));
        if (is_symchar (c)) {
	    /* Take read symbol as package name. */
            if (c == ':') {
		if (*p != -1)
		    lisperror (lispptr_invalid, "double package name");
		strcpy (p, os);
		len = 0;
		s = os;
		goto after_pname;
	    }

            *s++ = c;
            len++;
	    if (len > LISP_MAX_SYMLEN)
		lisperror_internal (lispptr_invalid,
			   "symbols must be no longer than %d chars",
			   LISP_MAX_SYMLEN);

	    if (len == 1 && c == '.')
		return len;
            continue;
        }

        *s++ = 0;
        if (len > 0)
	    lispio_putback (str);

        return len;
    }
}

/* Read token. */
void
lispread_token (struct lisp_stream *stream)
{
    unsigned  len = get_symbol (stream, LISPCONTEXT_TOKEN_NAME(),
	                        LISPCONTEXT_PACKAGE_NAME());
    char  c;

    if (len != 0) {
	LISPCONTEXT_TOKEN() = LISPTOKEN_SYMBOL;
	return;
    }

    switch (stream->last_char) {
        case '(':
	    LISPCONTEXT_TOKEN() = LISPTOKEN_BRACKET_OPEN;
	    break;
        case ')':
	    LISPCONTEXT_TOKEN() = LISPTOKEN_BRACKET_CLOSE;
	    break;
        case '.':
	    LISPCONTEXT_TOKEN() = LISPTOKEN_DOT;
	    break;
        case '\'':
	    LISPCONTEXT_TOKEN() = LISPTOKEN_QUOTE;
	    break;
        case '`':
	    LISPCONTEXT_TOKEN() = LISPTOKEN_BACKQUOTE;
	    break;
        case '"':
	    LISPCONTEXT_TOKEN() = LISPTOKEN_DBLQUOTE;
	    break;
        case ',':
	    c = lispio_getc (stream);
	    if (c == '@')
		LISPCONTEXT_TOKEN() = LISPTOKEN_QUASIQUOTE_SPLICE;
	    else {
	        LISPCONTEXT_TOKEN() = LISPTOKEN_QUASIQUOTE;
		lispio_putback (stream);
	    }
	    break;
        case '#':
	    c = lispio_getc (stream);
	    if (c == '\\') {
		LISPCONTEXT_TOKEN() = LISPTOKEN_CHAR;
		break;
	    }
            if (c != '\'')
		lisperror_norecover (lispptr_invalid, "syntax error after '#'");
            LISPCONTEXT_TOKEN() = LISPTOKEN_FUNCTION;
	    break;
        case -1:
	    LISPCONTEXT_TOKEN() = 0;	/* end of file */
	    break;
    }
}

/*
 * Read ordinary atom.
 */
lispptr
lispread_atom (struct lisp_stream *stream)
{
    char      str[LISP_MAX_STRINGLEN + 1];
    char      *i;
    char      c;
    unsigned  l;
    lispptr package;

    /* Read string atom. */
    if (LISPCONTEXT_TOKEN() == LISPTOKEN_DBLQUOTE) {
        i = str;
	l = 0;
	while (1) {
	    c = lispio_getc (stream);

            if (c == '"')
		break;
            if (c == '\\')
		c = lispio_getc (stream);
	    *i++ = c;
	    if (++l > LISP_MAX_STRINGLEN)
		return lisperror (lispptr_invalid,
                                  "string must be no longer than %d chars",
			          LISP_MAX_STRINGLEN);
	}
	*i = 0;
	return lispstring_get (str);
    }

    if (LISPCONTEXT_TOKEN() == LISPTOKEN_CHAR)
        return lispatom_number_get ((float) lispio_getc (stream),
                                    LISPNUMTYPE_CHAR);

    if (LISPCONTEXT_TOKEN() < LISPTOKEN_SYMBOL)
	return lisperror (lispptr_invalid, "syntax error");

    package = (*LISPCONTEXT_PACKAGE_NAME() == -1) ?
	          lispptr_nil :
	          lispatom_get (LISPCONTEXT_PACKAGE_NAME(), lispptr_nil);

    return lispatom_get (LISPCONTEXT_TOKEN_NAME(), package);
}

lispptr lispread_expr (struct lisp_stream *stream);

/* Expand quotation shortcut to special form. */
lispptr
lispread_quote (struct lisp_stream *stream)
{
    lispptr  atom;
    lispptr  expr;

    switch (LISPCONTEXT_TOKEN()) {
	case LISPTOKEN_QUOTE:
	    atom = lispatom_quote;
	    break;
	case LISPTOKEN_BACKQUOTE:
	    atom = lispatom_backquote;
	    break;
	case LISPTOKEN_QUASIQUOTE:
	    atom = lispatom_quasiquote;
	    break;
	case LISPTOKEN_QUASIQUOTE_SPLICE:
	    atom = lispatom_quasiquote_splice;
	    break;
	case LISPTOKEN_FUNCTION:
	    atom = lispatom_function;
	    break;
	default:
	    return lisperror (lispptr_invalid,
                              "lispread_quote: unsupported token");
    }

    expr = lispread_expr (stream);
    expr = CONS(expr, lispptr_nil);
    return CONS(atom, expr);
}

/*
 * Continue reading an expression.
 */
lispptr
lispread_list (struct lisp_stream *stream)
{
    lispptr  car;
    lispptr  cdr;
    lispptr  ret;

    /* Read CAR. */
    switch (LISPCONTEXT_TOKEN()) {
	case LISPTOKEN_QUOTE:
	case LISPTOKEN_BACKQUOTE:
	case LISPTOKEN_QUASIQUOTE:
	case LISPTOKEN_QUASIQUOTE_SPLICE:
	case LISPTOKEN_FUNCTION:
	    /* Expand quote. */
	    car = lispread_quote (stream);
	    break;

	case LISPTOKEN_BRACKET_OPEN:
	    /* Step into new expression. */
            lispread_token (stream);
	    car = lispread_list (stream);
	    break;

	case LISPTOKEN_BRACKET_CLOSE:
	    return lispptr_nil;

	default:
	    /* Read single atom. */
	    car = lispread_atom (stream);
    }

    lispgc_push (car);

    /* Read CDR. */
    lispread_token (stream);
    switch (LISPCONTEXT_TOKEN()) {
	case LISPTOKEN_DOT:
	    /* Read atom or expression. */
            cdr = lispread_expr (stream);
            lispread_token (stream);
            if (LISPCONTEXT_TOKEN() != LISPTOKEN_BRACKET_CLOSE)
		goto error;
	    break;
	case LISPTOKEN_BRACKET_CLOSE:
	    /* End of expression reached. */
	    cdr = lispptr_nil;
	    break;
	default:
	    /* Continue reading current expression. */
            cdr = lispread_list (stream);
    }

    /* Cons CAR & CDR. */
    ret = CONS(car, cdr);
    lispgc_pop ();
    return ret;

error:
    lispgc_pop ();
    return lisperror (lispptr_invalid, "closing bracket expected");
}

/* Read an expression or atom. */
lispptr
lispread_expr (struct lisp_stream *stream)
{
    lispread_token (stream);

    if (LISPCONTEXT_TOKEN() == 0) /* End of file. */
        return lispptr_invalid;

    /* Expand quote. */
    if (LISPCONTEXT_TOKEN() >= LISPTOKEN_QUOTE
     && LISPCONTEXT_TOKEN() <= LISPTOKEN_FUNCTION)
	return lispread_quote (stream);

    /* Read atom. */
    if (LISPCONTEXT_TOKEN() != LISPTOKEN_BRACKET_OPEN)
	return lispread_atom (stream);

    /* Test on empty list. */
    lispread_token (stream);	/* Skip opening bracket. */
    if (LISPCONTEXT_TOKEN() == LISPTOKEN_BRACKET_CLOSE)
        return lispptr_nil;

    /* Read expression. */
    return lispread_list (stream);
}

lispptr
lispread (struct lisp_stream *stream)
{
    lispio_prompt ();

    /* Test on empty file. */
    lispio_skip_spaces (stream);
    if (lispio_eof (stream))
	return lispptr_invalid;

    return lispread_expr (stream);
}

void
lispread_init ()
{
    LISPCONTEXT_TOKEN() = (int) -1;
    LISPCONTEXT_TOKEN_NAME()[0] = 0;

    /* Reader expansions. */
    lispatom_quote = lispatom_get ("QUOTE", LISPCONTEXT_PACKAGE());
    lispatom_backquote = lispatom_get ("BACKQUOTE", LISPCONTEXT_PACKAGE());
    lispatom_quasiquote = lispatom_get ("QUASIQUOTE", LISPCONTEXT_PACKAGE());
    lispatom_quasiquote_splice = lispatom_get ("QUASIQUOTE-SPLICE", LISPCONTEXT_PACKAGE());
    lispatom_function = lispatom_get ("FUNCTION", LISPCONTEXT_PACKAGE());

    EXPAND_UNIVERSE(lispatom_quote);
    EXPAND_UNIVERSE(lispatom_backquote);
    EXPAND_UNIVERSE(lispatom_quasiquote);
    EXPAND_UNIVERSE(lispatom_quasiquote_splice);
    EXPAND_UNIVERSE(lispatom_function);
}
