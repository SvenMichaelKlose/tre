
# Overview

This is tré, a metamorphic Lisp transpiler.  It can generate
Common Lisp (SBCL) and ECMAScript/JavaScript.

tré has been used in real life business for a couple of years and is
now cleaned up for the public.  That's why generating PHP, C and bytecode
is broken at them moment.  tré is also still unable to compile itself
across targets.


# Building and installing

Make sure you have sbcl installed installed.  Then, simply run:

```
./make.sh boot
./make.sh install
```

# Invokation

The installed binary is named "tre".  It takes an optional pathname
of a source file to compile and execute.  If none is specified, it'll
prompt you for expressions to execute.


# Working applications:

https://github.com/SvenMichaelKlose/bender/
