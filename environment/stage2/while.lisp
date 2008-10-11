;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defmacro while (test result &rest body)
  "Loops over body unless test evaluates to NIL and returns result."
  `(do ()
	   ((not ,test) ,result)
	 ,@body))
