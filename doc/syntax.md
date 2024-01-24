# Syntax

tré comes with a lot of syntactical sugar to keep things snappy.

## No LAMBDA symbol required

The LAMBDA symbol may be omitted when defining functions.
(Influenced by Arc.)

```lisp
; Old style.
#'(lambda (args)
    function-body)

; tré style.
#'((args)
    function-body)
```

## Dots instead of CAR or CDR

Probably inspired by some COBOL manual, tré takes
the edge off by removing the zoo of CAR, CDR and related
expressions.  Instead of doing "(car x)" you are now invited to
use "x." instead.  The equivalent for "(cdr x)" would be ".x".
You can also combine the two dots, so "(cadr x)" is ".x." for the
second element.  To access the third element "(caddr x)" just do
"..x.".

```lisp
x.      ; (car x)
.x      ; (cdr x)
.x.     ; (cadr x)
..x.    ; (caddr x)
..x..   ; (caaddr x)
```

It does not work around parentheses yet.

## Dot instead of CONS

```lisp
; Old style.
(cons a b)

; tré style.
(. a b)
```

## Brackets '[]' for anonymous functions

Inspired by Arc

```lisp
[expr]

[(expr1)
 (expr2)]
```

is the equivalent of

```lisp
#'((_)
    (expr))

#'((_)
    (expr1)
    (expr2))
```

If 'expr' starts with a symbol, it is wrapped into a list to
form an expression.

PROPOSAL!  NOT IMPLEMENTED YET:
Tré also lets you make your own argument definitions.  To roll
your own basically end them with a closing parenthesis:

```lisp
[body]              #'((_) body)
[) body]            #'(() body)
[x) body]           #'((x) body)
[x &rest y) body]   #'((x rest y) body)
```

## Braces '{}' to make JSON objects

If you open an expression with a curly brace it'll become a
JSON object.

```lisp
{
  "item2"  "2" ; It's highly recommended to use strings!
  :item1   "1"
  :oh-no   3   ; Will be converted to camel notation and result in "ohNo".
}
```

## General abbreviations

Inspired by the C syntax these are synonyms for what you
would otherwise expect from Common Lisp.  The original names
are, most of the time, still there.

* == instead of =
* = instead of SETF
* ? instead of IF
* & instead of AND
* | instead of OR
* / instead of DIV

Due to name collision the original meaning of '=' is gone
in favour of '=='.

There are also abbreviations for some anaphoric macros
inspired by Arc (which are there as well):

* != instead of ALET (Arc)
* !? instead of AIF (Arc)
* !@ instead of ADOLIST (Arc) (See also '@'.)


## @ instead of DOLIST or FILTER

Also warks with arrays.

```lisp
; Use as FILTER.
(@ #'filter-function x)
```

```lisp
; Use as DOLIST.
(@ (i x)
  (filter-function/return-value-lost i))
```

## +@ instead of MAPCAN

Only works for lists.

## BACKQUOTE for anonymous macros

These are QUASIQUOTEs aka commas outside BACKQUOTEs aka backticks
aka '`'.  They are evaluated before the standard macro expansion
pass.

```lisp
(progn
  ,@(generate-some-code-expressions))
```

## PROPOSAL: Comma for dynamic SLOT-VALUE access (NOT IMPLEMENTED)

When working with JSON data for example lots of SLOT-VALUE
expressions can spoil the fun.  Here's an example:

```lisp
(slot-value slot name)  ; Old style.
slot.,name              ; New style.
```
