# Overview

This is tré, a metamorphic Lisp transpiler.  It can generate
Common Lisp (SBCL), JavaScript (for browsers and node.js) and
PHP code.

tré has been used in real life business for a couple of years and is
now cleaned up for the public.

tré has been developed since 2005 by Sven Michael Klose <pixel@hugbox.org>.

# Building and installing

Make sure you have sbcl (Steel Bank Common Lisp) installed.
Then, simply run:

```
./make.sh boot
./make.sh install
```

# Invokation

The installed binary is named "tre".  It takes an optional pathname
of a source file to compile and execute.  If none is specified, it'll
prompt you for expressions to execute.
