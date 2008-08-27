LISTS

	<para>
    	One can create a list of symbols by embracing them with round brackets
    	(see special characters).
	</para>

		(1 2 3)
		A list with three symbols.

	<para>
    	Lists may also be nested, forming trees:
	</para>

		(1 (2 3))
		A list containing symbol 1 and another list with symbols 2 and 3.

LIST ELEMENTS

	<para>
    	TRE knows three forms for notating cell elements. All variants
    	behave the same:
	</para>

		1. The dot special form. (. a b)
		2. The dot-in-the-middle special form. (a . b)
		3. The CONS special form. (CONS a b)

ABBREVIATED TREE NOTATION

	<para>
    	To reduce the number of round brackets, curly brackets can be used instead.
    	Like with round brackets, expressions opened with curly brackets must
    	be ended with the same number of closing curly brackets. But all missing
    	round brackets that come after a curly bracket are closed implicitly.
		This is syntactically correct expression:

    	{format t "Hello world number ~A!" (+ 1 1}
	</para>

	<para>
		The curly bracket is intended to save many round brackets where it can be
		noticed easily: at the end of deeply nested branches.
	</para>

    	{html
      	`(head (title "My document"))
       	(body
         	(h1 "Phone numbers from the database")
         	{table
           	,@(foreach result (mysql-query "SELECT * FROM people"
                                          	:database "people-db"
                                          	:host "localhost"
                                          	:user "sven" :password "fnord")
               	^(tr
                  	(td [result "name"])
                  	(td [result "phone"])}
         	(a :href "/" "Link back home")}
