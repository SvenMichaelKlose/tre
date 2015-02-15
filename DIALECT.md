# JavaScript target

This is the most used target.

## Global variables

Global variables are not bound to symbols.

## Character type

The character type is emulated and must be converted with
CHAR-CODE before passing them to native JavaScript
functions.

## NIL

NIL is the same as 'false'.

## Hash tables

Hash tables are native arrays with special key handling, so
any data type can be used as a key. EQ and == (and its typed
variants) are the fastest. All other test functions are
iterated over the array.


# C/SBCL target

These targets have no dynamically sized arrays.


# PHP target

## Object identity

The PHP target trades garbage collection for object identity
of symbols, conses and arrays – to make EQ work.

## Hash tables

Hash tables are wrapped, native PHP arrays with symbols,
strings and numbers as keys only.
