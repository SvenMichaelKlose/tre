; tré – Copyright (c) 2008,2011–2012,2015 Sven Michael Klose <pixel@copei.de>

(defmacro fn (&body body)
  `#'((_)
        (block nil
	      ,@(? (& (cons? (car body))
			      (not (eq '%slot-value (car (car body)))))
			   body
			   (list body)))))

(defmacro square (&body body)
  `(fn ,@body))
