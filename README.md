# IMPORTANT:

!!! Under reconstruction with help of SBCL !!!


# Overview

This is tré, a metamorphic Lisp transpiler.  It can generate C,
ECMAScript/JavaScript, PHP and a dedicated bytecode.


# Building and installing

Make sure you have sbcl installed installed.  Then, simply run:

```
./make.sh boot
./make.sh install
```


# Invokation

The installed binary is named "tre". It takes an optional pathname
of a source file to compile and execute.
