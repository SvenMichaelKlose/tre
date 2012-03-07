;;;;; tré - Copyright (c) 2008,2012 Sven Michael Klose <pixel@copei.de>

(defmacro repeat (n &rest body)
  `(dotimes (,(gensym) ,n)
	 ,@body))
