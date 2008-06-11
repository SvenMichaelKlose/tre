(section
	(title "Syntax")
	(para
    	"The interpreter reads single characters from the input stream and"
    	"groups them into symbols and special characters. With special"
    	"characters are grouped in to lists and trees.")

	(para
    	"Lowercase letters are converted to uppercase. These are the special"
    	"characters which may not be used with symbols; their uses will be"
    	"explained in the following sections of this manual:")

    (item-list
        (item
			(element "Whitespaces")
			(description "Including spaces and control characters, like the tabulator."))
        (item
			(element "(")
			(description "Opens an expression"))
        (item
         	(element ")")
			(description "Closes an expression"))
        (item
         	(element "{")
			(description "Opens a parent expression"))
        (item
         	(element "}")
			(description "Closes a parent expression"))
        (item
	 		(element "[")
			(description "Open index expression"))
        (item
	 		(element "]")
			(description "Close index expression"))
        (item
	 		(element ".")
			(description "Dot, denoting a cell"))
        (item
	 		(element "'")
			(description "Quote"))
        (item
	 		(element "`")
			(description "Backquote"))
        (item
	 		(element "^")
			(description "Collecting quote"))
        (item
	 		(element ",")
			(description "Comma"))
        (item
	 		(element "#")
			(description "Read macro escape."))
        (item
	 		(element ";")
			(description "Comment (ignore everything until end of line)"))
        (item
	 		(element "\"")
			(description "Start/end of a character string constant"))
        (item
	 		(element "$")
			(description "(XXX already used)  Accumulator set/get, catching the value of the following object."))
        (item
	 		(element ":")
			(description "Namespace delimiter."))
        (item
	 		(element "|")
			(description "Start/end of character sequence without limitations.")))

	(para
    	"These characters may be used in future version of TRE:"
		"@$%&\?~"))
