;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro let-if (x expr &body body)
  `(let ,x ,expr
	 (? ,x
	    ,@body)))
