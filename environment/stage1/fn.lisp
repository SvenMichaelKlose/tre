;;;;; TRE environment
;;;;; Copyright (C) 2008 Sven Klose <pixel@copei.de>

(defmacro fn (&rest body)
  `#'((_)
	    ,@(if (consp (car body))
			  body
			  (list body))))
