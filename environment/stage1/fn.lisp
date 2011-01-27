;;;;; TRE environment
;;;;; Copyright (c) 2008,2011 Sven Klose <pixel@copei.de>

(defmacro fn (&rest body)
  `#'((_)
	    ,@(? (and (cons? (car body))
				  (not (eq '%slot-value (car (car body)))))
			 body
			 (list body))))
