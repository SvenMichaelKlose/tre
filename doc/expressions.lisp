EXPRESSIONS

	<para>
    	If the interpreter read a top-level list, it evaluates the list; the
    	list is interpreted as a function call, starting with a function object,
    	continued by its arguments. This is why the two examples above cause
    	an error if typed into the command prompt (the first elements are
    	numbers, not functions. '+' is a built-in function that would do
    	something useful:
	</para>

		* (+ 2 3)
		5

	<para>
    	This is a list of object types of the TRE programming language:
	</para>

		- variable; refers to other objects. It may be assigned a
	  	function object and any other object that is not a function at the
	  	same time,
		- number, contains a single floating-point value,
        	- array, contains a fixed number of objects that can be indexed
	  	using indices starting with 0,
		- strings, contains sequences of 0 or more characters,
		- built-in functions, essential functions required to build the
	  	language with user-defined functions
		- built-in special forms; built-in function without argument
		- user-defined functions
		- user-defined special forms, also known as 'macros'
		- and list elements, referred to as 'conses'.

	<para>
    	Symbols are variables which point to themselves.
	</para>

	<para>
    	Expressions are singly-linked lists. They are opened and closed with
    	round brackets, '(' and ')' respectively. "(1 2 3)" would be a valid
    	expression with three elements. It cannot be typed into the prompt
    	because when expressions are evaluated, they're expected to be
    	function calls.
	</para>
