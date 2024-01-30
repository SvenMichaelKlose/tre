# Transpiler/compiler

This is a micropass compiler, translating the code in numerous
simple steps.  The more the merrier as that's easier to debug.
The passes are split up into "ends": the front-, middle and
back-end.  All code has to go through the front-end before the
other ends in order to collect as much data as possible required
to generate code of acceptable efficiency.

Aside from gathering that information the front-end breaks down
the code into assembly-style control flow made of goto statements
only.  It also moves expressions out of argument lists by assigning
them to temporary variables which replace them in the argument lists.
The middle-end connects the dots by building a tree of FUNINFO
objects and performs tailcall and peephole optimizations.
The back-end is left to generate the code.  Stack places are
assigned here if required (e.g. for C, bytecode or PHP closures).

# Table of Contents

1. [Front-end](environment/transpiler/front-end/README.md)
2. [Middle-end](environment/transpiler/middle-end/README.md)
3. [Back-end](environment/transpiler/back-end/README.md)
4. [Common LISP target](environment/transpiler/targets/common-lisp/README.md)
