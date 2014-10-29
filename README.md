# Overview

This is tré, a metamorphic transpiler for a dialect of the Lisp
family of programming languages.  It can generate C,
ECMAScript/JavaScript, PHP and a dedicated bytecode.  Except for
PHP tré can compile itself to all other targets.


# IMPORTANT:

The bytecode target is currently broken.
The JavaScript target works but just not for the whole transpiler.


# Building and installing

Make sure you have binutils, git, gcc, and the development
version of libc, libdl, libffi installed.  Then, simply run

```
./make.sh boot
./make.sh install
```

and enjoy yourself for a couple of minutes.  The interpreter
is rather slow, but things get boosted after the initial round
of which there are two.  

The binary is installed to /usr/local/bin/tre.


# Invokation

Invoke tré with the -h argument and it tells you all it knows
about its command-line options and arguments.

```
tre -h
```


# The interpreter

Opposite to the compiler the interpreter has no lexical scopging
but surprisingly it copes with the compiler source anyway.
Hopefully, the interpreter is replaced by the compiler, soon.


# Dialect

The dialect's most notable features are:

- lexical scoping (except for the interpreter),
- anonymous macros (QUASIQUOTE doesn't need BACKQUOTE),
- a terse dot-notation CAR and CDR.
- no LAMBDA symbol required in literal functions


# Documentation

You'll find Markdown files here and there.  Their number is growing,
so keep looking out.
