FUNCTIONS

	<para>
    	All functions require a list of argument definitions.
    	Each element of the list is a symbol representing a value passed to the
    	function or a keyword specifying optional or keyword-associated arguments.
    	Argument definitions may be nested.
	</para>

    	(defun myfun (name (surname middle-name)) ... )
    	(myfun "Klose" ("Sven" "Michael"))

	<para>
    	The interpreter accepts the &REST, &OPTIONAL and &KEY keywords in
    	argument list definitions.
	</para>

	<para>
    	The &REST keyword will return a list of remaining arguments.
	</para>

	<para>
    	The &OPTIONAL keyword will initialise following missing arguments to
    	NIL.
	</para>

    	* (#'((&optional var) var))
    	NIL

	<para>
    	An alternative intialisation value may be declared inside a list:
	</para>

    	* (#'((&optional (var 23) var))
    	23

	<para>
    	The &KEY keyword will search for the following keywords in the
    	arguments passed to the function and will take the following value.
    	Usually the keyword namespace is specified by prepending a colon ':'
    	to the keyword when calling the function. If a key was not specified,
    	it is initialised to NIL.
	</para>

    	* (#'((&key comment) (print comment)) :comment "FNORD!")
    	"FNORD"

SPECIAL FUNCTIONS

	<para>
    	A special functions is like an ordinary function but is evaluated
    	in the environment of its caller. Arguments are not evaluated.
	</para>
