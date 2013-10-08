# JavaScript target

## Global variables

This is the most used target. Global variables aren't bound
to symbols.

## Character type

The character type is emulated by internal character objects
and must be converted via CHAR-CODE before being passed to
native JavaScript functions.

## NIL

NIL is the same as the boolean 'false'.

## Hash tables

Hash tables are native arrays with special key handling, so
any data type can be used as a key. EQ and == (and its typed
variants) are the fastest. All other test functions are
iterated over the array.


# Interpreter

An interpreter without lexical scoping to boot the compiler
with the C target.


# C target

The C target has no dynamically sized arrays.


# PHP target

## Object identity

The PHP target trades garbage collection for object identity
of symbols, conses and arrays.

## Hash tables

Hash tables are wrapped, native PHP arrays with symbols,
strings and numbers as keys only.
