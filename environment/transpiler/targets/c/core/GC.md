This is a simple mark-and-sweep garbage collector maintaining
statically-sized pools of conses and atoms in the arrays of the same
names.  Anything that shouldn't be removed by it must be connected
to the symbol *UNIVERSE* in some way or be placed on the dedicated,
garbage-collected stack in array `trestack', whose pointer is
`trestack_ptr'.  There's even a second, garbage-collected stack
(trestack_secondary) which is only used by the bytecode interpreter.
