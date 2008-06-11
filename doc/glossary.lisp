### TERMINOLOGY ############################################################

    expression, S-expression ("symbolic expression")
	A textual representation of an object.

    non-atomic S-expression ("dotted-pair")
	A binary tree of conses whose leaf nodes are atoms.

    pure list
	An S-expression where every element x

	    (AND (NOT (CONSP (CAR x)))
	         (LISTP (CDR x)))
	    => T
