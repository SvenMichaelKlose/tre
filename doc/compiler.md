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

The front-end works in three stages:

* expansion,
* augmentation, and
* serialization.

During expansion all macros are processed and literal data is transformed into
code generating it, if so required.  During augmentation every function is
ensured to get a name and is applied a FUNINFO.  During serialization function
body expressions are unnested, resulting in the meta-code ready to pass on to
the middle-end.

## Expansion stage

The expansion stage includes

* dot-notation expasion
* transpiler-macro expansion,
* compiler-macro expansion
* quote expansion and
* thisification.

Transpiler-macro expansion is a regular macro expansion where the standard
macros are overlaid by transpiler-macros of equal names which defined within
the compiler to handle exceptions the selected target.  Compiler-macros
transform control-flow forms like BLOCK, COND, PROGN, TAGBODY and so on to use
only four meta-code instructions:

| Meta-code                    | Description                |
|------------------------------|----------------------------|
| (%VAR name)                  | Global or local variable   |
|------------------------------|----------------------------|
| (%NEW class-name &rest args) | Inlined make object.       |
|------------------------------|----------------------------|
| (%SLOT-VALUE x slot-name)    | Inlined SLOT-VALUE         |

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
| (%BLOCK &rest body)    | Code block behaving like a mix of PROGN and |
|                        | TAGBODY.                                    |

%BLOCKs are removed later during expression expansion and are implied in
function bodies.  They are there to avoid having to unnest %BLOCKs early.
Also worth noting is the %COMMENT meta-code to help development:

| Meta code         | Description                                 |
|------------------------------------------------------------------
| (%COMMENT string) | Comment to insert in the final code output. |

Quote expansion compiles all QUOTE and BACKQUOTE expressions to CONSing ones
whereas thisification adds 'this' to objects inside methods.  (More on that
later.)  QUOTEs must have only one argument after this point.

## Augmentation

Augmentation includes

* renaming arguments,
* lambda expansion and FUNINFO initialization.

Lambda expansion makes sure that every function has a name and creates a
FUNINFO for that name.  The FUNINFO only contain the functions' argument
definitions and links to their parent FUNINFOs at this point.  Functions may be
inline and closures may be exported, meaning that their are turned into
top-level functions with a scope argument.

| Meta code                    | Description                       |
|------------------------------|-----------------------------------|
| (%SET-LOCAL-FUN var expr)    | defunct                           |
|------------------------------|-----------------------------------|
| (FUNCTION name (args body…)) | Named function (with FUNINFO)     |
|------------------------------|-----------------------------------|
| (%CLOSURE name)              | Allocates a scope record.         |

## Serialization

Expression expansion is the only pass doing serialization.  It moves function
calls out of arguments lists and unnests %BLOCK expressions so that all
function bodies are pure lists of %= expressions, tags and jumps.  %BLOCK
expressions have been removed entirely.  %VAR expressions are collected and
the names are added to the FUNINFOs.  Also, literals are handled in this pass.

That's for too much for a single pass within a micro-pass architecture.  It'll
be split up into:

1. **Literal expasions**: Literals must be collected and registered.
1. **Call expasions**: Arguments are expanded and rest arguments are made
   consing.
2. **Expression expansion**: To _single statement assignments_: All arguments
   of function calls are assigned to temporary variables.
3. **Block folding**: Collapses nested %BLOCKs.
3. **Collecting %VARs**: Moves %VAR declarations to their FUNINFOs.
4. **Assigment compaction**: Removes %= from assignments' heads.
5. **Tag compaction**: Replaces %TAGs by numbers.

| Secondary meta-codes   | Description                                 |
|------------------------|---------------------------------------------|
| (%= place value)       | Assignment to place.                        |
| (%= place (fun [args…) |                                             |
|------------------------|---------------------------------------------|
| (%GLOBAL name)         | Global variable.                            |
|------------------------|---------------------------------------------|
| (%BLOCK &rest body)    | **REMOVED** in front-end output!            |
|------------------------|---------------------------------------------|
| (%VAR name)            | Variable declaration.                       |

# Middle-end

* Repeated expression expansion now that all argument definitions are known
  and need to get checked for us.
* Unassigning named functions and accumulating top-level expressions: functions
  are moved to the front so they are available to all other top-level
  expressions.
* Collecting keywords: Needs to be done by a new _literal expansion pass_ in the
  frontend.
* Meta-code validation: Make sure it's clean.
* Optimizations
* Peeohole optimization
* Tail-call optimization: just working a little as variables are not traced
  thoroughly.
* Chained jump removal
* Removing unused tags
* Removing unused places

# Back-end

| Meta-codes                       | Description                            |
|----------------------------------|----------------------------------------|
| (%STACK idx)                     | Local variable on stack.               |
|----------------------------------|----------------------------------------|
| (%STACKARG idx)                  | Argument on stack. (C/bytecode target) |
|----------------------------------|----------------------------------------|
| (%VEC seq idx stack-position)    | Scope record read.                     |
|----------------------------------|----------------------------------------|
| (%SET-VEC val seq idx)           | Scope record write.                    |
|----------------------------------|----------------------------------------|
| (%FUNCTION-PROLOGUE name)        | Head and tail of function bodies.      |
| (%FUNCTION-EPILOGUE name)        |                                        |
|----------------------------------|----------------------------------------|
| (%AREF arr idx)                  | Native array accessors.                |
| (%=-AREF val arr idx)            |                                        |
|----------------------------------|----------------------------------------|
| (%MAKE-OBJECT class-name kvlist) | Make CLASS object.                     |
|----------------------------------|----------------------------------------|
| (%MAKE-JSON-OBJECT kvlist)       | Make (native) JSON object.             |

* Adding function frames.  Each function body is pre- and postfixed with an
  %FUNCTION-PROLOGUE and %FUNCTION-EPILOGUE macro to aid the codegen pass.
* Place expansion: wraps variables in %STACK, %STACKARG or %VEC/%SET-VEC
  forms (the latter for accessing scoped variables).
* Place assignment: layouts the stack frames and scope records.
* Collecting used functions to generate a list of unused ones.
* Translating function names: converts function names to identifier strings
  required by the target machine, usually in camel-case.
* String encapsulation (for codegen): wraps literal strings in a %STRING form
  so the can be told apart from code string during codegen macro expansion.
* Counting tags for no real reson.
* Wrapping tags: again to identify them during codegen macro expansion.
* Codegen macro expansion: here al the target code is made by codegen macros.
* Identifier conversion: converts any symbol left as well as characters and
  literal strings into target format (e.g. escaped strings in double quotes).
