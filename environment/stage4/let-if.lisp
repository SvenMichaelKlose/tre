;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro let-if (x expr &rest body)
  `(let ,x ,expr
	 (if ,x
	   ,@body)))
