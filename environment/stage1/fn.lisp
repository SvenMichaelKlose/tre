;;;;; TRE environment
;;;;; Copyright (C) 2008 Sven Klose <pixel@copei.de>

(defmacro fn (&rest body)
  `#'((_)
	    ,@(if (and (consp (car body))
				   (not (eq '%slot-value (car (car body)))))
			  body
			  (list body))))
