;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defmacro let-when (x expr &body body)
  `(let ,x ,expr
	 (when ,x
	   ,@body)))
