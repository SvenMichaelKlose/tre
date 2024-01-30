tré environment
===============

# Table of Contents

1. [Stage 0](environment/stage0/README.md)
2. [Stage 1](environment/stage1/README.md)
3. [Stage 2](environment/stage2/README.md)
4. [Stage 3](environment/stage3/README.md)
5. [Stage 4](environment/stage4/README.md)
6. [Stage 5](environment/stage5/README.md)
6. [Tests](environment/tests/README.md)

Here you find the general-purpose code and the transpiler.  Files of the
name 'main.lisp' load each section using function ENV-FILE.  ENV-FILE can
load files for particular targets only.

~~~lisp
; Load file for Common LISP, PHP or JS target.
(env-load "some-file.lisp" :cl :php :js)
~~~

The environment starts with functions handling lists, numbers and symbols
and gradually grows with functions for more complex data types: arrays,
hash tables, structures, objects and JSON objects.  Finally the transpiler
is added, followed by basic tests which are also executed on the spot.

# Names

Functions and macros starting with a percent sign '%' are not indented to
be used by anything outside the environment.
Double percent signs help to wrap functions.
Triple percent signs denote functions that belong to a particular target.
