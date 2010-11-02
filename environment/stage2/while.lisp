;;;;; TRE environment
;;;;; Copyright (c) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defmacro while (test result &rest body)
  `(do ()
	   ((not ,test) ,result)
	 ,@body))

(defmacro awhile (test result &rest body)
  `(do ((! nil))
	   ((not (setq ! ,test)) ,result)
	 ,@body))
