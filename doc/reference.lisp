### FUNCTION REFERENCE #####################################################

TERMINOLOGY

    LISTS

    If something must be a list, it must be a cons or NIL (see also LISTP).

    A documentation has the following form:

    (name argument-definition) - type of function
	Descriptive text.

   'type of function' may be one or both of

	- non-standard
	- built-in

    followed by

	- function
	- special form
	- macro.

    Optionally, '(r)' tells that the function cannot be implemented in
    TRE to run the interpreter.

<section>
	<title>Numbers</title>

	<para>
    	Only floating point numbers are supported.
			</para>
</section>

<section>
	<title>Comparison</title>

	<cmd name="EVENP" type="f">
		<args>
			<arg name="x"/>
		<args>
		<para>
	Returns T if x is an even number.
		</para>
	</cmd>

	<cmd name="NEQL" type="non-standard function">
		<args>
			<arg name="x"/>
			<arg name="y"/>
		<args>
		<para>
	Like (not (eql x y)).
		</para>
	</cmd>


	<cmd name="NOT" type="f">
		<args>
			<arg name="x"/>
		<args>
		<para>
	Returns T if x is not NIL.
		</para>
	</cmd>

	<cmd name="NULL" type="f">
		<args>
			<arg name="x"/>
		<args>
		<para>
	Same as LISTP. Returns T if x is a cons.
		</para>
	</cmd>


	<cmd name="RANGE-P" type="f" flavour="tre">
		<args>
			<arg name="num"/>
			<arg name="bottom"/>
			<arg name="top"/>
		<args>
		<para>
	Returns T if the number is within the range starting at bottom
	and ending at top (>= bottom and &lt;= top).
		</para>
	</cmd>

</section>

<section>
	<title>TYPES</title>

    (ZEROP x) - function
	Returns T if x contains the number 0.

CHARACTERS

SYMBOLS

	($ &REST args) - non-standard macro
	Converts all arguments to strings, concatenates them and makes a symbol.

VARIABLES

    (DEFCONSTANT variable &OPTIONAL init-value) - macro
	Defines and initialises a constant variable which cannot be 
	modified with SETF.

    (DEFVAR variable &OPTIONAL init-value) - macro
	Defines and initialises a variable.

    (LABELS ((function_name argument_list body)*) exprs) - macro
	Create local functions visible while evaluating
	'exprs'. Local functions may call themselves or formerly
	defined functions.

    (LET ((symbol value)*) body) - macro
	Call body in a new environment where symbol is locally assigned
	a new value. This macro generates a single LAMBDA.

    (LET* ((symbol value)*) body) - macro
	Call body in a new environment where symbol is locally assigned
	a new value. Value expressions may contain symbols formally
	initialised. This macro generates nested LAMBDAs.

    (MULTIPLE-VALUE-BIND variables expression body*) - macro
        Binds variables to VALUES returned by expression and
        evaluates the body. If the list of variables is longer than the
	list values returned by the expression, the remaining variables
	are set to NIL. Remaining values are ignored.

    (SET symbol value) - macro
	Give symbol an evaluated value.

    (SETF {place value}*) - macro
	Gives 'place' a new unevaluated value. If place is a getter
	function call it is expanded to the correspondig setter,
	e.g. a call to CAR is transformed to a call to RPLACA.
        Returns 'value'. See also DEFUN.

    (VALUES expression*) - function
        Returns multiple values for MULTIPLE-VALUE-BIND.

    (WITH (symbol/list expr ...)) - macro
	This macro is a merge of LET* and MULTIPLE-VALUE bind. It expects
	pairs instead of expressions. If a symbol is the first element of
	a pair, it behaves like LET*. If the destination is a list of
	symbols, WITH behaves like MULTIPLE-VALUE-BIND.

    (XCHG a b) - macro
	Swaps values of the arguments.

MATH

    (1+ x) - function
	Return x incremented by 1.

    (1- x) - function
	Return x decremented by 1.

    (ABS x) - function
	Return positive value of x.

    (DECF place &OPTIONAL (n 1)) - macro
	Decrement place by n.

    (INCF place &OPTIONAL (n 1)) - macro
	Increment place by n.

BIT OPERATIONS

	(BIT-OR x y) - builtin function
	Bitwise OR of two integers. Returns an integer.

	(BIT-AND x y) - builtin function
	Bitwise AND of two integers. Returns an integer.

	(<< x num-bits) - builtin function
	Shift integer x num-bits left. Returns an integer.

	(>> x num-bits) - builtin function
	Shift integer x num-bits right. Returns an integer.

CONS

    (FIRST | SECOND | THIRD | FOURTH | FIFTH | SIXTH | SEVENTH | EIGHTH |
     NINTH | TENTH list) - function
	These functions return the first, up to the tenth, element of a list.

    (RPLAC-CONS cons cons-new) - non-standard function
	Replaces the values of cons by the values of cons-new.

LISTS

    (APPEND &REST lists) - function
	Returns 'lists' concatenated. All lists are copied.

    (CAAR list) - function
	Like (CAR (CAR list)).

    (CADAR list) - function
	Like (CDR (CAR list)).

    (CADR list) - function
	Like (CAR (CDR (CAR list))).

    (CDAR list) - function
	Like (CDR (CAR list)).

    (CDDR list) - function
	Like (CDR (CDR list)).

    (COPY-LIST tree) - function
	Returns toplevel copy of list of tree.

    (COPY-TREE tree) - function
	Returns copy of a list including all sublevels.

    (LAST list) - function
	Returns last cons of a list.

    (LISTP x) - function
	Returns T if x is a cons or NIL.

    (NTH index lst) - function
	Return element at position 'index' from 'lst', starting with 0.
	NIL is returned if 'index' exceeds the number of elements.

    (NTHCDR index list) - function
        Returns the nth CDR of a list. An index of 0 returns the first
        cons.

LIST MANIPULATION

    (ADJOIN object list) - function
	If object is a member of list, returns list. Otherwise, the list
	is returned with the object prepended.

    (REMOVE-IF test-function list) - function
	Remove elements from list.

    (REVERSE list) - function
	Returns reversed copy of a pure.

    (NCONC list*) - function
        Concatenates lists into single list by replacing the cdr of each
        last cons and returns it. (This function is destructive.)

LIST SEARCH

    (MEMBER element list*) - function
	Returns T if element is a member of any of the pure lists.

LIST TRAVERSAL

    (DEFINE-MAPPED-FUN mapfun name arg-list &REST body) - non-standard
	function
	Creates a function which takes a list and calls mapfun for
	traversal. arg-list and body are used to create a function
	which serves as the first argument to mapfun. The argument to
	the created function will be the second argument to mapfun.

    (DEFINE-MAPCAR-FUN name arg-list &REST body) - non-standard function
	Like DEFINE-MAPPED-FUN but with mapfun set to MAPCAR.

    (MAP function list*) - function
	Call function with each cons of the lists as arguments.
	On the first call the first conses in the lists are used, on the
	second call the second conses are applied, and so on, until a
	list runs out of elements.
	MAP always evaluated to NIL.

    (MAPCAR function list*) - function
	Like MAP but the return values of the function are returned in a list.

    (MAPCAN function list*) - function
	Like MAPCAR but concatenates the lists returned by the function.
	A LISTP on every return value must evaluate to T.

FUNCTIONS

    (DEFUN name args documentation-string body) - macro
	Defines a global function. The body is placed in a BLOCK named
	NIL and a TAGBODY.
	The documentation string is added to *DOCUMENTATION* and should
	be received through function DOCUMENTATION.
	If name is a list of the form (SETF name), the function is called
    if 'name' is used as a SETF place. It must then take the value
	as the first argument, and the place as the second argument.

    (DOCUMENTATION funcname) - function
	Returns documentation string of function.

	Create new function or return function bound to variable.

MACROS

    (DEFINE-COMPILER-MACRO (name args body) - macro
	Defines a macro which is used by the compiler to translate
	built-in functions to native TRE expressions.

    (DEFMACRO name args documentation-string body) - macro
	Like DEFUN but the arguments are not evaluated before the macro
   	is called and the body's result value is evaluated after return from
	the body.

    (GENSYM) - function
	Returns new generic symbol.

    (MACROLET ((function_name argument_list body)*) exprs) - not implemented
	Like LET* for LABELS.

    (WITH-GENSYM { symbol | symbol-list } &REST body) - macro
	Creates one or more gensyms for evaluation of body.

EVALUATION

    (BACKQUOTE expression) - special form
	Evalates QUASIQUOTE and QUASIQOTE-SPLICE in expression and
	returns it. The short form is "`expression".

    (FUNCALL function &REST args) - function
        Calls function with arguments.

    (QUASIQUOTE expression) - keyword
	Evaluate expression within a BACKQUOTE and insert it into the point
	of return. The short form is ",expression".

    (QUASIQUOTE-SPLICE expression) - keyword
	Evaluate expression within a BACKQUOTE. The return value of the
	expression must be a list which is spliced into the point of return.
        The short form is ",@expression".

COMPILATION

    (COMPILE functionname) - function
        Compiles a function and returns it. See the compiler section
	of this manual for more details.

    (COMPILE-ALL) - function
	Compile just everything.

CONTROL FLOW

    (AIF test-expression true-body [false-body]) - non-standard macro
	Like IF but assigning the value of 'test' to variable '!'.

    (ANIF name test-expression true-body [false-body]) - non-standard macro
	Like IF but assigning the value of 'test' to variable 'name'.

    (ANWHEN name test expressions*) - non-standard macro
	Like WHEN but assigning the value of 'test' to variable 'name'.

    (AWHEN test expressions*) - non-standard macro
	Like WHEN but assigning the value of 'test' to variable '!'.

    (CASE value (match expression?)*) - macro
        Evaluates first expression whose 'match' is EQUAL to 'value'.
		Expression is optional,

    (PROG1 expression*) - macro
	Evaluates expressions and returns the value of the first.

    (UNLESS test expression*) - macro
	Same as (WHEN (NOT test) expression*).

    (WHEN test expressions*) - macro
	Evaluate expressions in order, returning the value of the last
        if test is not NIL

    (WHILE test result &REST body*) - macro
	Loops over body unless test evaluates to NIL and returns result.

ERRORS

    (ERROR format &rest format-args) - function
	Print format string and enter debugging mode.

ITERATION

    (DOLIST (var list [result]) expressions*) - macro
	Create new local variable var and evaluate expressions for each
	element in list.
        The DOLIST expansion is encapsulated in a block named NIL
	(see RETURN). The result is returned if it is specified, otherwise
	NIL is returned.

LOOPS

    (DOTIMES (var integer [result]) body*) - macro
        Counts local variable var from 0 up to the integer value - 1
	and evaluate body expressions each time.
        The DOTIMES expansion is encapsulated in a block named NIL
	(see RETURN). DOTIMES returns the result if it is specified,
        otherwise NIL is returned.

    (DO (var init [update])* (test [result]*) body*) - macro
	Initialise each var to init and evaluate body as long as test
        evaluates to NIL. After evaluation of the body, all variables
	are updated. 'result' is evaluated on return if specified.

    (LOOP &REST body) - macro
	Infinitely loop over body. The CL loop language is not
	implemented.

ASSOC LISTS

    (ASSOC key list) - function/place
	Looks up pair in associative list.

    (ASSOC-CONS key list) - function
	Like ASSOC but returning the cons containing the key and the value.

    (ACONS key val lst) - function
	Prepends key/value pair to associative list.

    (ACONS! key val place) - non-standard macro
	Like ACONS but sets place.

    (PAIRLIS key-list value-list) - function
	Merges key and value list into an associative list. An error is
	issued if the lists don't have the same length.

    (CARLIST alist) - function
	Returns keys of an associative list.

    (CDRLIST alist) - function
	Returns values of an associative list.

    (COPY-ALIST alist) - function
	Return a copy of an associative list. Keys and values are
	the same.

STACKS

    (PUSH value stack) - macro
	Prepend element to list and return it.

    (POP stack) - macro
        Return first element from list and make 'stack' point to the
	next element.

    (POP! stack) - non-standard function
	Like POP but replacing the registers of the first elements by
	the registers of the second element.

CHARACTERS

    (ALPHA-CHAR-P char) - function
	Returns T if 'char' is an alphabetic character.

    (ALPHANUMERICP char) - function
	Returns T if 'char' is an alphabetic character or a digit.

    (CHAR-DOWNCASE char) - function
	Returns the lower case equivalent of 'char' or 'char' itself.

    (CHAR-UPCASE char) - function
	Returns the upper case equivalent of 'char' or 'char' itself.

    (DIGIT-CHAR-P char) - function
	Returns T if 'char' is a digit.

    (LOWER-CASE-P char) - function
	Returns T if 'char' is a lower case, alphabetic character.

    (UPPER-CASE-P char) - function
	Returns T if 'char' is an upper case, alphabetic character.

STRINGS

    Strings are not unique. (EQ "a" "a") evaluates to NIL. Use STRING=
    instead. Strings are also sequences.

    (LIST-STRING string) - non-standard function
	Makes string from list of numbers. If string is NIL, NIL is returned.
    
    (STRING-DOWNCASE string) - function
	Return new string with lower case characters.

    (STRING-UPCASE string) - function
	Return new string with upper case characters.

    (STRING= str1 str2) - function
	Returns T if strings match.

ARRAYS

HASH TABLES

    (GETHASH key hash-table &OPTIONAL default) - function/place
	Lookup element with 'key' from 'hash-table'. 'optional' is
	unused.

    (MAKE-HASH-TABLE &KEY test size rehash-size rehash-threshold) -
	function
	Makes a new hash table. 'test' is a predicate function, which
	is #'EQ by default. 'size' is the table size (not limiting the
	total number of elements). 'rehash-size' and 'rehash-threshold'
        are unused.

	Currently, only numbers and strings can be used as keys.

QUEUES *NON-STANDARD*

    (DOLIST-QUEUE (var queue [result]) expressions*) - macro
	Like DOLIST for queues.

    (ENQUEUE queue value) - macro
	Place value on top of queue.

    (MAKE-QUEUE) - macro
	Makes the head element of a queue.

    (QUEUE-LIST) - macro
	Return the list of queue elements.

    (QUEUE-POP queue) - macro
	Pops first element off the queue and returns it.

    (WITH-QUEUE { name | name-list} &REST body) - macro
	Creates one or more queues before body is evaluated.

SEQUENCES

    Lists and strings are sequences.

    (SOME predicate &REST sequences) - function
	Returns T if 'predicate' returns T for any element of 'sequences'.

    (EVERY predicate &REST sequences) - function
	Returns T if 'predicate' returns T for all elements of 'sequences'.

    (FIND value sequence &KEY start end from-end test test-not)
	Finds element in list. 'start' and 'end' define the starting and
	ending index searched. 'start' and 'end' may be swapped to make
	sense. If 'from-end' is not NIL, the search is performed backwards.
	The default testing predicate may be overridden by 'test' or
	'test-not'. The boolean returned by the 'test-not' function will
	be negated.

    (FIND-IF predicate sequence &KEY start end from-end) - function
	Finds element in list for which 'predicate' returns T. 'start'
	and 'end' define the starting and ending index searched. 'start'
	and 'end' may be exchanged to make sense. If 'from-end' is not NIL,
	the search is performed backwards.

	(IN? element &rest list) - function
	Checks if element is EQ to any list element.

	(IN=? element &rest list) - function
	Checks if element is = to any list element. Will be obsoleted if TEST
	keyword can follow &REST.

    (POSITION value sequence &KEY start end from-end test test-not) - function
	Like FIND, but returning the position of the element found
	(zero-indexed) or NIL.

    (SUBSEQ sequence start &OPTIONAL end) - function
	Return copy of subsequence of the same type. The ending position is
    not included. Copies from lists, arrays and strings.
	Returns NIL if 'sequence' is NIL.

	(GROUP sequence size) - function
	Break up sequence into list of pieces of 'size' elements (or less at the end).

STRUCTURES

    (DEFSTRUCT name &REST fields) - macro
	Defines a structure of name 'name' with 'fields'. A constructor named
	'MAKE-name' is defined. For each field a getter function is defined
        of name 'name-field' which may be used as a place with SETF.

	A field in 'fields' may be a symbol or a list containing the
	symbol and its init form:

	    (defstruct mystruct
	      fnord		      ; Will be initialised to NIL.
	      (text "Hello World!"))  ; Field will contain the string.

	In one of 'fields' the :constructor option may be used, specifying
	the name of the constructor which would otherwise be MAKE-name.

    (WITH-STRUCT struct-name var &REST body) - non-standard macro
	Binds all fields of structure 'var' of type 'structure-name' to
	equally named variables for the evaluation of 'body'.

STREAMS

    If the optional stream argument is not give, the standard input or
    output stream is used.

    (END-OF-FILE &OPTIONAL stream) - function
        Returns T is stream is at the end of a file. NIL otherwise.

    (FORCE-OUTPUT &OPTIONAL stream) - function
	Force buffered output out.

    (FRESH-LINE &OPTIONAL stream) - function
	Open a new line not already done.

    (FRESH-LINE? &OPTIONAL stream) - non-standard function
	Checks if output stream is at the beginning of a line.

    (GET-STREAM-STRING string-stream) - function
	Returns string accumulated string-stream. The stream is emptied.
	See also MAKE-STRING-OUTPUT-STREAM.

    (MAKE-STRING-STREAM) - function
	Returns a stream which accumulates all strings written to
        it. See also GET-OUTPUT-STREAM-STRING.

    (PRINC obj &OPTIONAL stream) - function
        Print obj in human-readable format.

    (PEEK-CHAR &OPTIONAL stream) - function
	Peek next character from input stream. The character will remain
        in the stream.

	(READ &OPTIONAL stream) - function
	Reads and returns expression from stream.

    (READ-CHAR &OPTIONAL stream) - function
	Take character from input stream.

    (READ-INTEGER &OPTIONAL stream) - function
	Read decimal integer from stream.

    (READ-LINE &OPTIONAL stream) - function
	Read line from stream.

    (TERPRI &OPTIONAL stream) - function
	Open a new line.

    (WITH-DEFAULT-STREAM str &REST body) - non-standard macro
	Set 'str' to *standard-output* if 'str' is T or create a
	string-stream if 'str' is NIL, evaluate 'body' and return the
        stream-string if 'str' is NIL.
 
PRINTING

	(FORMAT stream format &rest format-args) - function
	Prints format to stream. Inside the format string "~A"s are replaced
	by format-argument elements in the same order. "~%" is replaced by
	newlines.
	When stream is t, FORMAT prints to *standard-output*. If it is NIL,
	a string is returned.

ARGUMENTS

    (ARGUMENT-EXPAND argument-definition values) - function
	Expands argument and returns two flat lists (see VALUES). The
	first contains the argument keywords, the second contains the
	values.

EXECUTABLES AND IMAGES

PROCESSES

	(EXEC path (&REST args) &OPTIONAL (environment nil)) - function
		Overlay current process with program at 'path'.
		'args' is a list of argument strings.
		'environment' may be an associative list of variable/value pairs.

	(FORK) - function
		Creates a copy instance of the current process. Returns the new
		process-ID to the calling process and 0 to the new process.

	(WAIT) - function
		Waits until a child process exits. Returns a status integer as
		specified in the UNIX man page wait (2).

ALIEN INTERFACE

    The alien interface allows to link shared libraries and to call C
    functions.

MISCELLANEOUS

INTERNAL FUNCTIONS

    Internal functions should never be used outside the initial environment,
    since misuse will cause damage to the environment.

    %SET-ELT
    %SET-AREF
	SETF setters for built-in functions.

### VIRTUAL FUNCTIONS #######################################################

    This functions are low-level primitives to break up code into simpler
    units by expandings compiler macros. They're just symbols used by
    compiler, not real functions.

    (%FUNREF fun obj)
	Combines a function reference with the first argument that must
        be passed to that function.

    (%SET atom expr)
        Same as SETQ, but taking only two arguments.

    (%VEC vec index)
        Place of an array element.

    (%VM-SCOPE &BODY body)
	Like a TAGBODY, but returns the last expression evaluated.

    ~%RET
        This is a placeholder for return values of VM-SCOPEs.

### GLOBAL CORE VARIABLES ###################################################

    *ENVIRONMENT-PATH*
	Root directory of the environment.

    *MACROEXPAND-HOOK*
	Points to function which takes an expression and does a single
        macro-expansion like MACROEXPAND-1.

    *VERBOSE-EVAL*
	When set to T, everything passed to the EVAL function is PRINTed
	before.

    %LAUNCH-FILE
	A TRE file specified on the command-line, evaluated after the
	environment.

### GLOBAL ENVIRONMENT VARIABLES ############################################

    *CURRENT-MACRO*
	Set to macro function before it is called (during macro-expansion)
        and reset to NIL after its return.

	*CONSTANTS*
	A list of symbols defined with DEFCONSTANT.

	*DEFUN-NAME*
	Name of currently epanded, DEFUNed function.

	*FIRST-TO-TENTH*
	Contains all symbols from FIRST to TENTH.

    *STRUCT-DEFS*
	An associative array of all structure definitions make with DEFSTRUCT.

    *UNIVERSE*
	List of all symbols that should not be removed.

    *VERBOSE-EVAL*
	When set to T, everything passed to the EVAL function is PRINTed
	before.
