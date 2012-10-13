;;;;; tré – Copyright (c) 2008,2011–2012 Sven Michael Klose <pixel@copei.de>

(defmacro fn (&rest body)
  `#'((_)
	    ,@(? (& (cons? (car body))
			    (not (eq '%slot-value (car (car body)))))
			 body
			 (list body))))

(defmacro square (&rest body)
  `(fn ,@body))
