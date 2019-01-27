# Overview

tré compiles its own dialect of Lisp to JavaScript and PHP.
Its for web developers who know a bit of Common Lisp or Arc
already.


# Building and installing

Make sure you have sbcl (Steel Bank Common Lisp) installed.
Then run:

```
./make.sh boot
./make.sh install
```

The installed binary is named "tre" in /usr/local/bin.  It
takes an optional pathname of a source file to compile and
execute.  If none is specified, it'll prompt you for
expressions to execute.


# Syntax

tré comes with a lot of syntactical sugar and it's probably
the best thing to get started with if you know Lisp already.

* to get rid of those embarrassing parentheses
* to keep one from repeating oneself

## General abbreviations

Inspired by the C syntax these are synonyms for what you
would expect from Common Lisp (which should also be there).

* == instead of =
* = instead of SETF
* ? instead of IF
* & instead of AND
* | instead of OR
* / instead of DIV

There are also abbreviations for some anaphoric macros
inspired by Arc:

* != instead of ALET (Arc)
* !? instead of AIF (Arc)
* !@ instead of ADOLIST (Arc) (See also '@'.)

## Dots instead of CAR or CDR

Probably inspired by some COBOL manual tré first of all
takes the edge off by removing the zoo of CAR, CDR and
related expressions.  Instead of doing "(car x)" you are now
invited to use "x." instead.  The equivalent for "(cdr x)"
would be ".x".  You can also combine the two dots, so "(cadr
x)" is ".x." or use more than one dot.  To access the second
element "(caddr x)" just do "..x.".

```
x.      ; CAR
.x      ; CDR
.x.     ; CADR
..x.    ; CADDR
..x..   ; CAADDR

```

## Square brackets [] for anonymous functions

Inspired by Arc

```
[body]
```

is the equivalent for

```
#'((_) body)
```

If 'body' starts with a symbol, it is wrapped in a list to
form an expression.

NOT IMPLEMENTED YET:
Tré also lets you make your own argument definitions.
To roll your own basically end them with a syntax-violating
closing round bracket:

```
[body]              #'((_) body)
[) body]            #'(() body)
[x) body]           #'((x) body)
[x &rest y) body]   #'((x rest y) body)
```

## Curly brackets {} to make JSON objects or instead of PROGN

If you open an expression with a curly brace it'll become a
MAKE-OBJECT if the first element is a keyword or a string.
Then the argument is grouped into key/value pairs.
Otherwise it'll become a PROGN.

```
; Use as PROGN (first element is not a string or keyword).
(| x
   {(do-something)
    (do-something-else)}

; Use as MAKE-OBJECT.
{item1    "1"
 "item2"   "2"}
```

## At sign instead of DOLIST or FILTER

```
; Use as FILTER.
(@ #'filter-function x)
```

```
(@ (i x)
  (filter-function/return-value-lost i))
```

## Comma for anonymous macros

These are QUASIQUOTEs aka commas outside BACKQUOTEs aka
backticks aka '`'.  They are evaluated before the standard
macro expansion pass.

```
Some exciting example missing here.
```

## Comma for dynamic SLOT-VALUE access (NOT IMPLEMENTED)

When working with JSON data for example lots of SLOT-VALUE
expressions can spoil the fun.  Here's an example:

```
(slot-value slot name)  ; Old style.
slot.,name              ; New style.
```
