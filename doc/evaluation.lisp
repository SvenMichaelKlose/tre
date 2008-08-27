EVALUATION

	<para>
    	As soon as a token or expression was read its elements are executed
    	(also called 'evaluation' for the rest of this document) and replaced by
    	their return values. The first element must be a function which is
    	called with the remaining elements as its arguments.
	</para>

        * (+ 1 2)
        3

        [Call to function '+' with arguments 1 and 2. 3 is the returned
         value.]

	<para>
    	As noted before, expression elements may also be expressions:
	</para>

        * (+ 1 (+ 2 3))

	<para>
    	first evaluates to
	</para>

		(+ 1 5)

	<para>
    	and then to
	</para>

		6
