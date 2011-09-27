/*
 * TRE tree processor
 * Copyright (c) 2005-2008,2010 Sven Klose <pixel@copei.de>
 *
 * Reading TRE expressions.
 */

#include "config.h"
#include "atom.h"
#include "list.h"
#include "io.h"
#include "read.h"
#include "string2.h"
#include "gc.h"
#include "thread.h"
#include "number.h"
#include "error.h"

#include <ctype.h>
#include <string.h>

/*
 * Token values.
 *
 * Don't forget to update is_symchar().
 */
#define TRETOKEN_EOF			0	/* end of file */
#define TRETOKEN_BRACKET_OPEN	1
#define TRETOKEN_BRACKET_CLOSE	2
#define TRETOKEN_DOT			3
#define TRETOKEN_DBLQUOTE		4
#define TRETOKEN_QUOTE			5
#define TRETOKEN_BACKQUOTE		6
#define TRETOKEN_QUASIQUOTE		7
#define TRETOKEN_QUASIQUOTE_SPLICE	8
#define TRETOKEN_FUNCTION		9
#define TRETOKEN_CHAR			10
#define TRETOKEN_HEXNUM			11
#define TRETOKEN_SYMBOL			12	/* Keep this at the end. */

#define TRETOKEN_IS_QUOTE(x) \
	(x >= TRETOKEN_QUOTE && x <= TRETOKEN_FUNCTION)

/*
 * Check if the next incoming character would be legal part of a symbol.
 */
bool
is_symchar (unsigned char c)
{
    return (c > ' ' && c != '(' && c != ')' && c != '\'' && 
			c != '`' && c != ',' && c != '"' && c != ';' &&
			c != '#' && c != 255);
}

/*
 * Read symbol.
 *
 * Returns the length of the symbol or 0 if a special character or end
 * of input is read.
 */
int
get_symbol (struct tre_stream *str, char *s, char *p)
{
    ulong  len = 0;
    char   * os = s;
    char   c;
	bool   got_package = FALSE;

    *s = 0;
    *p = -1;
again:
    treio_skip_spaces (str);

    /* Ignore comments. */
    while (str->last_char == ';') {
        do { /* Read until line end. */
			c = treio_getc (str);
		} while (c != 10 && c != -1);
        goto again;
    }

after_pname:
    /* Read until a non-symbol character is found. */
    while (1) {
        c = toupper (treio_getc (str));
        if (is_symchar (c)) {
	    	/* Take read symbol as package name. */
            if (c == ':') {
				if (got_package)
		    		treerror (treptr_invalid, "double package name");
				strcpy (p, os);
				len = 0;
				s = os;
				got_package = TRUE;
				goto after_pname;
	    	}

            *s++ = c;
            len++;
	    	if (len > TRE_MAX_SYMLEN)
				treerror_internal (treptr_invalid,
			   					   "literal symbols must be no longer than %d chars",
			   					   TRE_MAX_SYMLEN);
            continue;
        }

        *s++ = 0;
        if (len > 0)
	    	treio_putback (str);

        return len;
    }
}

/* Read token. */
void
treread_token (struct tre_stream * stream)
{
    char   c;
    ulong  len = get_symbol (stream, TRECONTEXT_TOKEN_NAME(), TRECONTEXT_PACKAGE_NAME());

    if (len == 1 && TRECONTEXT_TOKEN_NAME()[0] == '.') {
    	TRECONTEXT_TOKEN() = TRETOKEN_DOT;
    	return;
	}

    if (len != 0) {
		TRECONTEXT_TOKEN() = TRETOKEN_SYMBOL;
		return;
    }

    switch (stream->last_char) {
        case '(':
	    	TRECONTEXT_TOKEN() = TRETOKEN_BRACKET_OPEN;
	    	break;
        case ')':
	    	TRECONTEXT_TOKEN() = TRETOKEN_BRACKET_CLOSE;
	    	break;
        case '\'':
	    	TRECONTEXT_TOKEN() = TRETOKEN_QUOTE;
	    	break;
        case '`':
	    	TRECONTEXT_TOKEN() = TRETOKEN_BACKQUOTE;
	    	break;
        case '"':
	    	TRECONTEXT_TOKEN() = TRETOKEN_DBLQUOTE;
	    	break;
        case ',':
	    	c = treio_getc (stream);
	    	if (c == '@')
				TRECONTEXT_TOKEN() = TRETOKEN_QUASIQUOTE_SPLICE;
	    	else {
	        	TRECONTEXT_TOKEN() = TRETOKEN_QUASIQUOTE;
				treio_putback (stream);
	    	}
	    	break;
        case '#':
	    	c = treio_getc (stream);
	    	if (c == '\\') {
				TRECONTEXT_TOKEN() = TRETOKEN_CHAR;
				break;
	    	}
	    	if (c == 'x') {
				TRECONTEXT_TOKEN() = TRETOKEN_HEXNUM;
				break;
	    	}
	    	if (c == '\'') {
            	TRECONTEXT_TOKEN() = TRETOKEN_FUNCTION;
				break;
	    	}
			treerror_norecover (treptr_invalid, "syntax error after '#'");
	    	break;
        case -1:
	    	TRECONTEXT_TOKEN() = TRETOKEN_EOF;
	    	break;
    }
}

/*
 * Read string atom.
 */
treptr
treread_string (struct tre_stream *stream)
{
    char   str[TRE_MAX_STRINGLEN + 1];
    char   * i;
    char   c;
    ulong  l;

    i = str;
	l = 0;
	while (1) {
		c = treio_getc (stream);

       	if (c == '"')
			break;
       	if (c == '\\')
			c = treio_getc (stream);
	   	*i++ = c;
	   	if (++l > TRE_MAX_STRINGLEN)
			return treerror (treptr_invalid,
                       	 	 "literal strings must be no longer than %d chars",
		             	 	 TRE_MAX_STRINGLEN);
	}
	*i = 0;
	return trestring_get (str);
}

bool
ishex (c)
{
	return isdigit (c) ||
		   (c >= 'A' && c <= 'F') ||
		   (c >= 'a' && c <= 'f');
}

treptr
treread_hexnum (struct tre_stream *stream)
{
	long v = 0;
	long n = 0;
	char c;

	while (1) {
	    c = toupper (treio_getc (stream));

		if (! ishex (c))
			break;

		v <<= 4;
		v += isdigit (c) ?
			 c - '0' :
			 c - 'A' + 10;
		n++;
	}

	treio_putback (stream);

	if (! n)
		return treerror (treatom_number_get ((double) c, TRENUMTYPE_CHAR),
				         "Missing characters after initiating hexadecimal number");

	if (! isspace (c) && isalpha (c))
		return treerror (treatom_number_get ((double) c, TRENUMTYPE_CHAR),
				         "Illegal character for hexadecimal number");

	return treatom_number_get ((double) v, TRENUMTYPE_INTEGER);
}

/*
 * Read ordinary atom.
 */
treptr
treread_atom (struct tre_stream *stream)
{
    /* Read string atom. */
    if (TRECONTEXT_TOKEN() == TRETOKEN_DBLQUOTE)
		return treread_string (stream);

    if (TRECONTEXT_TOKEN() == TRETOKEN_CHAR)
        return treatom_number_get ((double) treio_getc (stream), TRENUMTYPE_CHAR);

    if (TRECONTEXT_TOKEN() == TRETOKEN_HEXNUM)
        return treread_hexnum (stream);

    if (TRECONTEXT_TOKEN() < TRETOKEN_SYMBOL)
		return treerror (treptr_invalid, "syntax error");

    return treatom_get (
		TRECONTEXT_TOKEN_NAME(),
    	(*TRECONTEXT_PACKAGE_NAME() == -1)
	   		? treptr_nil
	   		: treatom_get (TRECONTEXT_PACKAGE_NAME(), treptr_nil)
	);
}

treptr treread_expr (struct tre_stream *stream);

/* Expand quotation shortcut to special form. */
treptr
treread_quote (struct tre_stream *stream)
{
    treptr  atom;
    treptr  expr;

    switch (TRECONTEXT_TOKEN()) {
		case TRETOKEN_QUOTE:
	    	atom = treatom_quote;
	    	break;
		case TRETOKEN_BACKQUOTE:
	    	atom = treatom_backquote;
	    	break;
		case TRETOKEN_QUASIQUOTE:
	    	atom = treatom_quasiquote;
	    	break;
		case TRETOKEN_QUASIQUOTE_SPLICE:
	    	atom = treatom_quasiquote_splice;
	    	break;
		case TRETOKEN_FUNCTION:
	    	atom = treatom_function;
	    	break;
		default:
	    	return treerror (treptr_invalid,
                             "treread_quote: unsupported token");
    }

    expr = treread_expr (stream);
    expr = CONS(expr, treptr_nil);
    return CONS(atom, expr);
}

/*
 * Continue reading an expression.
 */
treptr
treread_list (struct tre_stream *stream)
{
    treptr  car;
    treptr  cdr;
    treptr  ret;

    /* Read CAR. */
    switch (TRECONTEXT_TOKEN()) {
		case TRETOKEN_QUOTE:
		case TRETOKEN_BACKQUOTE:
		case TRETOKEN_QUASIQUOTE:
		case TRETOKEN_QUASIQUOTE_SPLICE:
		case TRETOKEN_FUNCTION:
	    	/* Expand quote. */
	    	car = treread_quote (stream);
	    	break;

		case TRETOKEN_BRACKET_OPEN:
	    	/* Step into new expression. */
            treread_token (stream);
	    	car = treread_list (stream);
	    	break;

		case TRETOKEN_BRACKET_CLOSE:
	    	return treptr_nil;

		default:
	    	/* Read single atom. */
	    	car = treread_atom (stream);
    }

    tregc_push (car);

    /* Read CDR. */
    treread_token (stream);
    switch (TRECONTEXT_TOKEN()) {
		case TRETOKEN_DOT:
	    	/* Read atom or expression. */
            cdr = treread_expr (stream);
            treread_token (stream);
            if (TRECONTEXT_TOKEN() != TRETOKEN_BRACKET_CLOSE)
				goto error;
	    	break;

		case TRETOKEN_BRACKET_CLOSE:
	    	/* End of expression reached. */
	    	cdr = treptr_nil;
	    	break;

		default:
	    	/* Continue reading current expression. */
            cdr = treread_list (stream);
    }

    /* Cons CAR & CDR. */
    ret = CONS(car, cdr);
    tregc_pop ();
    return ret;

error:
    tregc_pop ();
    return treerror (treptr_invalid, "closing bracket expected");
}

/* Read an expression or atom. */
treptr
treread_expr (struct tre_stream *stream)
{
    treread_token (stream);

    if (TRECONTEXT_TOKEN() == TRETOKEN_EOF)
        return treptr_invalid;

    /* Expand quote. */
    if (TRETOKEN_IS_QUOTE(TRECONTEXT_TOKEN()))
		return treread_quote (stream);

    /* Read atom. */
    if (TRECONTEXT_TOKEN() != TRETOKEN_BRACKET_OPEN)
		return treread_atom (stream);

    /* Test on empty list. */
    treread_token (stream);	/* Skip opening bracket. */
    if (TRECONTEXT_TOKEN() == TRETOKEN_BRACKET_CLOSE)
        return treptr_nil;

    /* Read expression. */
    return treread_list (stream);
}

treptr
treread (struct tre_stream *stream)
{
    treio_prompt ();

    /* Test on empty file. */
    treio_skip_spaces (stream);
    if (treio_eof (stream))
		return treptr_invalid;

    return treread_expr (stream);
}

void
treread_init ()
{
    TRECONTEXT_TOKEN() = (int) -1;
    TRECONTEXT_TOKEN_NAME()[0] = 0;

    /* Reader expansions. */
    treatom_quote = treatom_get ("QUOTE", TRECONTEXT_PACKAGE());
    treatom_backquote = treatom_get ("BACKQUOTE", TRECONTEXT_PACKAGE());
    treatom_quasiquote = treatom_get ("QUASIQUOTE", TRECONTEXT_PACKAGE());
    treatom_quasiquote_splice = treatom_get ("QUASIQUOTE-SPLICE", TRECONTEXT_PACKAGE());
    treatom_function = treatom_get ("FUNCTION", TRECONTEXT_PACKAGE());

    EXPAND_UNIVERSE(treatom_quote);
    EXPAND_UNIVERSE(treatom_backquote);
    EXPAND_UNIVERSE(treatom_quasiquote);
    EXPAND_UNIVERSE(treatom_quasiquote_splice);
    EXPAND_UNIVERSE(treatom_function);
}
