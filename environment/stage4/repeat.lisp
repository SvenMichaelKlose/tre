;;;;; tré – Copyright (c) 2008,2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro repeat (n &body body)
  `(dotimes (,(gensym) ,n)
	 ,@body))
