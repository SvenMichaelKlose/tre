The tré compiler
================

The compiler breaks up its input into the smallest possible units while
combining it with gathered information to then clean up the mess and generate
code for the desired target platform.  These steps are performed in the front-,
middle- and back-end respectively.  They are numerous, relatively simple and
incremental in a tangible fashion.[^1]  Each step is called a 'pass' and is
a more or less complicated kind of macro expansion where a tree is traversed to
rebuild it.  The first pass, for example is a call to MACROEXPAND and the last
pass, is a call of function FLATTEN which concatenates a tree of strings to a
single string: the compilation.  This chapter describes what happens in
between.

[^1]: Keyword "Micro-pass architecture".

The front-end is responsible for transforming its input into a format the
middle-end can process: the meta-code which is bridging the gap between the
high-level input and the low-level output of target code.  The meta-code is a
tree of functions, each function holding additional information gathered by
some passes and required by others.  The extra information is simply added by
giving each function a name and doing a look-up of a FUNINFO record with it.
That way the code tree can still be processed with standard functions, notably
PRINT for debugging.

The front-end works in three stages: expansion, augmentation and serialization.
During expansion all macros are processed and literal data is transformed into
code generating it, if so required.  During augmentation every function is
ensured to get a name and is applied a FUNINFO.  During serialization function
body expressions are unnested, resulting in the middle-end meta-code.

the initial meta-code is made of a handful of expressions.  More are added in
the back-end.

(%SLOT-VALUE x slot-name)
(%= var expr)
(%SET-LOCAL-FUN var expr)
%GO tag-name
%GO-NIL tag-name var
%GO-NOT-NIL tag-name var
(%TAG name)
(%%COMMENT &rest x)
(FUNCTION name (args &rest body))
(%CLOSURE name)
(%%%MAKE-JSON-OBJECT kwlist)
(%%%MAKE-OBJECT kwlist)
(%NEW class-name &rest args)

(%VEC seq idx)
(%SET-VEC val seq idx)
(%STACK idx)
(%STACKARG idx)
(%GLOBAL)
(%FUNCTION-PROLOGUE name)
(%FUNCTION-EPILOGUE name)
