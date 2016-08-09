; tré – Copyright (c) 2008,2011–2012,2015–2016 Sven Michael Klose <pixel@copei.de>

(defmacro square (&body body)
  `#'((_)
        (block nil
	      ,@(? (& (cons? body.)
			      (not (eq 'slot-value body..)
			           (eq '%slot-value body..)))
			   body
			   (list body)))))

(defmacro fn (&body body)
  (error "Macro FN has been removed.~%"))
