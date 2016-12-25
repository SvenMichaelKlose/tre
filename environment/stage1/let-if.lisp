(defmacro let-if (x expr &body body)
  `(let ,x ,expr
	 (? ,x
	    ,@body)))
