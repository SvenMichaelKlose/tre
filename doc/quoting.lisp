QUOTING

	<para>
    	Evaluation requires the first argument to be a function. This is why
    	lists cannot be entered literally to build data structures:
	</para>

        * (1 2 3)
        function expected instead of number '1'.

	<para>
    	To circumvent evaluation use the QUOTE special form. Special forms
    	are functions that take their arguments unevaluated. QUOTE returns
    	a copy of its unevaluated arguments:
	</para>

        * (quote (1 2 3))
        (1 2 3)

	<para>
    	Because quoting is used very often, there's an abbreviated form:
	</para>

        * '(1 2 3)
        (1 2 3)

	<para>
    	If you use the BACKQUOTE (or "`" for short, QUASIQUOTE (",") and
    	QUASIQUOTE-SPLICE (",@") functions insert their single evaluated
    	argument into the BACKQUOTEd expression.
	</para>

	<para>
    	QUASIQUOTE inserts an expression like a single atom.
	</para>

        * (setq a 3)
        3
        * `(1 ,a 2)
        (1 3 2)

	<para>
		When BACKQUOTE is nested, multiple QUASIQUOTES must be nested
		as well, to shield them from evaluation.
	</para>

	<para>
    	QUASIQUOTE-SPLICE splices a list into another
	</para>

        * (setq l '(7 8 9))
        (7 8 9)
        * `(1 ,@l 3)
        (1 7 8 9 3)

	<para>
    	COLLECTING-QUOTE collects a set of objects which is to be inserted by the
    	parent QUASIQUOTE or QUASIQUOTE-SPLICE. Its abbreviated form is the accent
    	circonflex ('^').
    	Each time a COLLECTING-QUOTE is evaluated, its result is appended to the
    	set.
	</para>
