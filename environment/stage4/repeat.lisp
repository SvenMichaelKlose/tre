;;;;; TRE environment
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defmacro repeat (n &rest body)
  "Execute body n times. See also DOTIMES."
  `(dotimes (,(gensym) ,n)
	 ,@body))
