### DEBUGGER ################################################################

	<para>
    	In case an error occured or (INVOKE-DEBUGGER) is evaluated, the
    	debugger is invoked, prompting you for input. It understands a set of
    	single-character commands. The debugger prompt has the following format.
	</para>

        [<return value>:]<debug level> ]

	<para>
    	The prompt may contain a return value:

        (1 2 3) : 1]
        1]

	<para>
    	Commands may take arguments; prefixed spaces are ignored: You may
    	type 'pSYMBOL' instead of 'p SYMBOL'.
	</para>

	<para>
    	Here is a list of all commands:
	</para>

    	Stack
		u	Move up to calling function.
        	d       Move back down a function.
		t	Print function-call backtrace.

    	Printing:

		p S	Print contents of symbol S. If the print contains the
                	currently evaluated expression, the expression is embraced
                	with arrows of the form "===>expression&lt;===".

    	Execution:

		s	Step into function.
		n	Execute expression including arguments.
		x E	Execute TRE expression.
        	*	Set return value, which is used to replace the
                	erroraneous expression when continuing.
                	You cannot set the return value if an error is
                	unrecoverable, which is printed when the debugger is
                	invoked.
        	c	Continue execution with current return value.

    	Breakpoints and watch expressions:

		b N	Set breakpoint for calls to function N. Prints names of
                	breakpointed functions if no arguments are given.
		k N	Remove breakpoint for function N.

    	Miscellaneous:

		h	Prints a help page
		q	Terminate program, return to toplevel.
</section>
