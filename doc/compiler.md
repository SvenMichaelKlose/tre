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

# Front-end

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
body expressions are unnested, resulting in the meta-code ready to pass on to
the middle-end.

## Expansion stage

The expansion stage includes dot-notation expasion, transpiler-macro expansion,
compiler-macro expansion quote expansion and thisification.
Transpiler-macro expansion is a regular macro expansion where the standard
macros are overlaid by transpiler-macros of equal names which defined within
the compiler to handle exceptions the selected target.
Compiler-macros transform control-flow forms like BLOCK, COND, PROGN, TAGBODY
and so on to use only four meta-code instructions:

| Control-flow meta code | Description                                 |
|------------------------|---------------------------------------------|
| (%TAG tag)             | Define a location to jump to.  The tag-name |
|                        | must be an integer.                         |
|------------------------|---------------------------------------------|
| (%GO tag)              | Unconditional jump.                         |
|------------------------|---------------------------------------------|
| (%GO-NIL tag var)      | Jump if variable is NIL                     |
| (%GO-NOT-NIL var)      | Jump if variable is not NIL.                |
|------------------------|---------------------------------------------|
| (%%BLOCK &rest body)   | Code block behaving like a mix of PROGN and |
|                        | TAGBODY.                                    |

%%BLOCKs are removed later during expression expansion and are implied in
function bodies.  They are there to avoid having to unnest %%BLOCKs early.
Also worth noting is the %%COMMENT meta-code to help development:

| Meta code          | Description                                 |
|-------------------------------------------------------------------
| (%%COMMENT string) | Comment to insert in the final code output. |

## Augmentation

Augmentation includes renaming arguments, lambda expansion, FUNINFO
initialization and expression expansion.


(%SLOT-VALUE x slot-name)
(%= var expr)
(%SET-LOCAL-FUN var expr)

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
