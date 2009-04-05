;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro let-when (x expr &rest body)
  `(let ,x ,expr
	 (when ,x
	   ,@body)))
