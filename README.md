# WARNING: UNDER RECONSTRUCTION!

Don't try to use tré for real work until this message is gone.

# Working applications:

https://github.com/SvenMichaelKlose/bender/

# Overview

This is tré, a metamorphic Lisp transpiler.  It can generate
Common Lisp (SBCL), C, ECMAScript/JavaScript, PHP and a
dedicated bytecode.


# Building and installing

Make sure you have sbcl installed installed.  Then, simply run:

```
./make.sh boot
./make.sh install
```


# Invokation

The installed binary is named "tre". It takes an optional pathname
of a source file to compile and execute.
