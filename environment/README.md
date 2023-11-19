tré environment
===============

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
