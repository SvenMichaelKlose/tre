(defmacro while (test result &body body)
  `(do ()
	   ((not ,test) ,result)
	 ,@body))

(defmacro awhile (test result &body body)
  `(do ((! nil))
	   ((not (setq ! ,test)) ,result)
	 ,@body))
