;;;;; tré – Copyright (c) 2005-2006,2008,2014 Sven Michael Klose <pixel@copei.de>

(defmacro while (test result &body body)
  `(do ()
	   ((not ,test) ,result)
	 ,@body))

(defmacro awhile (test result &body body)
  `(do ((! nil))
	   ((not (setq ! ,test)) ,result)
	 ,@body))
