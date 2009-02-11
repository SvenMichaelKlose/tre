### TERMINOLOGY ############################################################

	function-expression
		A literal expression of a function. It's a cell with a the
		function's arguments in its CAR and the body in it's CDR.
		See the FUNCTION special form.

	lambda-expression
		Lambda-expressions are function-expressions. Traditionally,
		such expressions were implemented as a special form
		named LAMBDA. That name can simply be left off.

    expression, S-expression ("symbolic expression")
	A textual representation of an object.

    non-atomic S-expression ("dotted-pair")
	A binary tree of conses whose leaf nodes are atoms.

    pure list
	An S-expression where every element x

	    (AND (NOT (CONSP (CAR x)))
	         (LISTP (CDR x)))
	    => T
