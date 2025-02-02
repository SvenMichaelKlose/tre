Front end
=========

The front end breaks the input code down into few basic instructions.

## DOT-EXPAND

This pass translates dot notations to CxR and SLOT-VALUE expressions.

## QUASIQUOTE-EXPAND

Treats QUASIQUOTEs outside QUOTEs as anonymous macros.

## TRANSPILER-MACROEXPAND

This macro expansion includes but overlays standard environment
macros.

## COMPILER-MACROEXPAND

Breaks down control flow expressions into test and jump instructions
inside %BLOCKs.  A %BLOCK combines TAGBODY and PROGN.

## QUOTE-EXPAND

Compiles QUOTE and BACKQUOTE expressions into CONSing ones.

## LITERAL-CONVERSION

Compiles literal characters into CODE-CHAR expressions.

## THISIFY

Provides implied access to methods and members inside classes
via THIS.

## RENAME-ARGUMENTS

Makes all argument names inside a top level expression unique
to avoid collisions later on.

## LAMBDA-EXPAND

Too much happening this pass at once:

* Unnamed functions get names in order to link them via FUNINFOs.
* Literal functions that are the first argument of an expressions are inlined.
* Closures are exported as top level functions.

## INITIALIZE-FUNINFOs

Now that all FUNINFOs are connected this initalises scoping information.

## EXPRESSION-EXPAND

Nested expressions are broken up and %%BLOCKs are bein removed.
After this pass a function body merely contains a single list of expressions.

## UNASSIGN-LAMBDAS

Moves functions out of %VAR expressions.

## GATHER-IMPORTS

Collects functions and variables that will be imported from the host
environment.
