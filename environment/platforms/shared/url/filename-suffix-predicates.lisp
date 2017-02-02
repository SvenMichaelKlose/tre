(defmacro define-file-ending-predicate (name)
  (let sname (downcase (symbol-name name))
    `(fn ,($ name '-suffix?) (x)
	   (== ,(+ "." sname)
		   (x.substr (- (length x) ,(++ (length sname))))))))

(mapcan-macro x
	'(html php css)
  `((define-file-ending-predicate ,x)))
