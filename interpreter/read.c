/*
 * tré – Copyright (c) 2005–2008,2010,2012–2014 Sven Michael Klose <pixel@copei.de>
 */

#include "config.h"

#ifdef INTERPRETER

#include <ctype.h>
#include <string.h>

#include "atom.h"
#include "cons.h"
#include "list.h"
#include "stream.h"
#include "read.h"
#include "string2.h"
#include "gc.h"
#include "thread.h"
#include "number.h"
#include "error.h"
#include "symtab.h"
#include "symbol.h"

#define TRETOKEN_EOF			       0
#define TRETOKEN_BRACKET_OPEN	       1
#define TRETOKEN_BRACKET_CLOSE	       2
#define TRETOKEN_DOT			       3
#define TRETOKEN_DBLQUOTE		       4
#define TRETOKEN_QUOTE			       5 /* beginning of quotes */
#define TRETOKEN_BACKQUOTE		       6
#define TRETOKEN_QUASIQUOTE		       7
#define TRETOKEN_QUASIQUOTE_SPLICE	   8
#define TRETOKEN_ACCENT_CIRCONFLEX	   9
#define TRETOKEN_FUNCTION		      10 /* end of quotes */
#define TRETOKEN_CHAR			      11
#define TRETOKEN_HEXNUM			      12
#define TRETOKEN_SQUARE_BRACKET_OPEN  13
#define TRETOKEN_SQUARE_BRACKET_CLOSE 14
#define TRETOKEN_CURLY_BRACKET_OPEN   15
#define TRETOKEN_CURLY_BRACKET_CLOSE  16
#define TRETOKEN_SYMBOL			      17 /* Keep this at the end. */

#define TRETOKEN_IS_QUOTE(x) \
	(x >= TRETOKEN_QUOTE && x <= TRETOKEN_FUNCTION)

bool
is_symchar (unsigned char c)
{
    return (c > ' ' &&
            c != '"' && c != ';' && c != '#' &&
            c != '(' && c != ')' &&
            c != '[' && c != ']' &&
            c != '{' && c != '}' &&
            c != '\'' && c != '`' && c != ',' && c != '^' &&
            c != 255);
}

int
get_symbol (trestream * str, char *s, char *p)
{
    size_t len = 0;
    char * os = s;
    char   c;
	bool   got_package = FALSE;

    *s = 0;
    *p = -1;
again:
    treio_skip_spaces (str);

    while (str->last_char == ';') {
        do {
			c = treio_getc (str);
		} while (c != 10 && c != -1);
        goto again;
    }

past_package_name:
    while (1) {
        c = toupper (treio_getc (str));
        if (is_symchar (c)) {
	    	/* Take read symbol as package name. */
            if (c == ':') {
				if (got_package)
		    		treerror (treptr_invalid, "Double package name.");
				strcpy (p, os);
				len = 0;
				s = os;
				got_package = TRUE;
				goto past_package_name;
	    	}

            *s++ = c;
            len++;
	    	if (len > TRE_MAX_SYMLEN)
				treerror_internal (treptr_invalid,
			   					   "Literal symbols must be no longer than %d chars.",
			   					   TRE_MAX_SYMLEN);
            continue;
        }

        *s++ = 0;
        if (len > 0)
	    	treio_putback (str);

        return len;
    }
}

void
treread_comment_block (trestream * stream)
{
    char c;
    
    while ((c = treio_getc (stream)) != 0) {
        if (c != '|')
            continue;
        c = treio_getc (stream);
        if (c == '#')
            return;
	    treio_putback (stream);
    }
}

void
treread_token (trestream * stream)
{
    char   c;
    size_t len = get_symbol (stream, TRECONTEXT_TOKEN_NAME(), TRECONTEXT_PACKAGE_NAME());

    if (len == 1 && TRECONTEXT_TOKEN_NAME()[0] == '.') {
    	TRECONTEXT_TOKEN() = TRETOKEN_DOT;
    	return;
	}

    if (len != 0) {
		TRECONTEXT_TOKEN() = TRETOKEN_SYMBOL;
		return;
    }

    switch (stream->last_char) {
        case '(': TRECONTEXT_TOKEN() = TRETOKEN_BRACKET_OPEN; break;
        case ')': TRECONTEXT_TOKEN() = TRETOKEN_BRACKET_CLOSE; break;
        case '[': TRECONTEXT_TOKEN() = TRETOKEN_SQUARE_BRACKET_OPEN; break;
        case ']': TRECONTEXT_TOKEN() = TRETOKEN_SQUARE_BRACKET_CLOSE; break;
        case '{': TRECONTEXT_TOKEN() = TRETOKEN_CURLY_BRACKET_OPEN; break;
        case '}': TRECONTEXT_TOKEN() = TRETOKEN_CURLY_BRACKET_CLOSE; break;
        case '\'': TRECONTEXT_TOKEN() = TRETOKEN_QUOTE; break;
        case '`': TRECONTEXT_TOKEN() = TRETOKEN_BACKQUOTE; break;
        case '"': TRECONTEXT_TOKEN() = TRETOKEN_DBLQUOTE; break;
        case '^': TRECONTEXT_TOKEN() = TRETOKEN_ACCENT_CIRCONFLEX; break;
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
	    	if (c == '|') {
                treread_comment_block (stream);
                treread_token (stream);
                break;
	    	}
			treerror_norecover (treptr_invalid, "Syntax error after '#'.");
	    	break;
        case -1:
	    	TRECONTEXT_TOKEN() = TRETOKEN_EOF;
	    	break;
    }
}

treptr
treread_string (trestream *stream)
{
    char   str[TRE_MAX_STRINGLEN + 1];
    char   * i;
    char   c;
    size_t l;

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
			return treerror (treptr_invalid, "Literal strings must be no longer than %d chars.", TRE_MAX_STRINGLEN);
	}
	*i = 0;
	return trestring_get (str);
}

bool
ishex (int c)
{
	return isdigit (c) ||
		   (c >= 'A' && c <= 'F') ||
		   (c >= 'a' && c <= 'f');
}

treptr
treread_hexnum (trestream * stream)
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
		return treerror (number_get_char ((double) c), "Missing characters after initiating hexadecimal number.");

	if (! isspace (c) && isalpha (c))
		return treerror (number_get_char ((double) c), "Illegal character for hexadecimal number.");

	return number_get_integer ((double) v);
}

treptr
treread_atom (trestream * stream)
{
    char * name = TRECONTEXT_TOKEN_NAME();
    double number;

    if (TRECONTEXT_TOKEN() == TRETOKEN_DBLQUOTE)
		return treread_string (stream);

    if (TRECONTEXT_TOKEN() == TRETOKEN_CHAR)
        return number_get_char ((double) treio_getc (stream));

    if (TRECONTEXT_TOKEN() == TRETOKEN_HEXNUM)
        return treread_hexnum (stream);

    if (TRECONTEXT_TOKEN() < TRETOKEN_SYMBOL)
		return treerror (treptr_invalid, "Syntax error.");

    if (trenumber_is_value (name)) {
        if (sscanf (name, "%lf", &number) != 1)
            treerror (NIL, "Illegal number format %s.", name);
        return number_get_float (number);
    }

    return symbol_get_packaged (
		name,
    	(*TRECONTEXT_PACKAGE_NAME() == -1) ?
            NIL :
            symbol_get (TRECONTEXT_PACKAGE_NAME())
	);
}

treptr treread_expr (trestream * stream);

treptr
treread_quote (trestream * stream)
{
    treptr  atom;
    treptr  expr;

    switch (TRECONTEXT_TOKEN()) {
		case TRETOKEN_QUOTE: atom = atom_quote; break;
		case TRETOKEN_BACKQUOTE: atom = atom_backquote; break;
		case TRETOKEN_QUASIQUOTE: atom = atom_quasiquote; break;
		case TRETOKEN_QUASIQUOTE_SPLICE: atom = atom_quasiquote_splice; break;
		case TRETOKEN_FUNCTION: atom = atom_function; break;
		case TRETOKEN_ACCENT_CIRCONFLEX: atom = atom_accent_circonflex; break;
		default:
	    	return treerror (treptr_invalid, "Unsupported token.");
    }

    expr = treread_expr (stream);
    expr = CONS(expr, NIL);
    return CONS(atom, expr);
}

treptr
treread_list (trestream * stream)
{
    treptr  car;
    treptr  cdr;
    treptr  ret;

    /* Read CAR. */
    switch (TRECONTEXT_TOKEN()) {
		case TRETOKEN_DOT:
            treread_token (stream);
            return CONS(atom_cons, treread_list (stream));

		case TRETOKEN_QUOTE:
		case TRETOKEN_BACKQUOTE:
		case TRETOKEN_ACCENT_CIRCONFLEX:
		case TRETOKEN_QUASIQUOTE:
		case TRETOKEN_QUASIQUOTE_SPLICE:
		case TRETOKEN_FUNCTION:
	    	car = treread_quote (stream);
	    	break;

        case TRETOKEN_BRACKET_OPEN:
            treread_token (stream);
            car = treread_list (stream);
            break;

        case TRETOKEN_SQUARE_BRACKET_OPEN:
            treread_token (stream);
            car = CONS(atom_square, treread_list (stream));
            break;

        case TRETOKEN_CURLY_BRACKET_OPEN:
            treread_token (stream);
            car = CONS(atom_curly, treread_list (stream));
            break;

		case TRETOKEN_BRACKET_CLOSE:
		case TRETOKEN_SQUARE_BRACKET_CLOSE:
		case TRETOKEN_CURLY_BRACKET_CLOSE:
	    	return NIL;

		default:
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
		case TRETOKEN_SQUARE_BRACKET_CLOSE:
		case TRETOKEN_CURLY_BRACKET_CLOSE:
	    	cdr = NIL;
	    	break;

		default:
            cdr = treread_list (stream);
    }

    ret = CONS(car, cdr);
    tregc_pop ();
    return ret;

error:
    tregc_pop ();
    return treerror (treptr_invalid, "Closing bracket expected.");
}

treptr
treread_expr (trestream * stream)
{
    treread_token (stream);

    if (TRECONTEXT_TOKEN() == TRETOKEN_EOF)
        return treptr_invalid;

    if (TRETOKEN_IS_QUOTE(TRECONTEXT_TOKEN()))
		return treread_quote (stream);

    switch (TRECONTEXT_TOKEN()) {
		case TRETOKEN_BRACKET_OPEN:
            treread_token (stream);
            if (TRECONTEXT_TOKEN() == TRETOKEN_BRACKET_CLOSE)
                return NIL;
            return treread_list (stream);

		case TRETOKEN_SQUARE_BRACKET_OPEN:
            treread_token (stream);
            return CONS(atom_square, treread_list (stream));
		case TRETOKEN_CURLY_BRACKET_OPEN:
            treread_token (stream);
            return CONS(atom_curly, treread_list (stream));
    }
    return treread_atom (stream);
}

treptr
treread (trestream * stream)
{
    treptr x;

    treio_skip_spaces (stream);
    if (treio_eof (stream))
	    return treptr_invalid;

    x = treread_expr (stream);

    return x;
}

void
treread_init ()
{
    TRECONTEXT_TOKEN() = (int) -1;
    TRECONTEXT_TOKEN_NAME()[0] = 0;

    atom_quote = symbol_get ("QUOTE");
    atom_backquote = symbol_get ("BACKQUOTE");
    atom_quasiquote = symbol_get ("QUASIQUOTE");
    atom_quasiquote_splice = symbol_get ("QUASIQUOTE-SPLICE");
    atom_function = symbol_get ("FUNCTION");
    atom_accent_circonflex = symbol_get ("ACCENT-CIRCONFLEX");
    atom_square = symbol_get ("SQUARE");
    atom_curly = symbol_get ("CURLY");
    atom_cons = symbol_get ("CONS");

    EXPAND_UNIVERSE(atom_quote);
    EXPAND_UNIVERSE(atom_backquote);
    EXPAND_UNIVERSE(atom_quasiquote);
    EXPAND_UNIVERSE(atom_quasiquote_splice);
    EXPAND_UNIVERSE(atom_function);
    EXPAND_UNIVERSE(atom_accent_circonflex);
    EXPAND_UNIVERSE(atom_square);
    EXPAND_UNIVERSE(atom_curly);
    EXPAND_UNIVERSE(atom_cons);
}

#endif /* #ifdef INTERPRETER */
