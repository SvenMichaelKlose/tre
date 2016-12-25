(defmacro repeat (n &body body)
  `(dotimes (,(gensym) ,n)
	 ,@body))
