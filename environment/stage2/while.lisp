;;;;; TRE environment
;;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defmacro while (test result &rest body)
  "Loops over body unless test evaluates to NIL and returns result."
  `(do ()
	   ((not ,test) ,result)
	 ,@body))

(defmacro awhile (test result &rest body)
  "Loops over body unless test evaluates to NIL and returns result.
   The test value is stored in variable !."
  `(do ((! nil))
	   ((not (setq ! ,test)) ,result)
	 ,@body))
