;;;; TRE environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>
;;;;
;;;; LET macro

;; Create new local variable.
(defmacro let (place expr &rest body)
  (cond
	((consp place)
	   (%error "place is not an atom"))

    (t `(#'((,place)
			  ,@body) ,expr))))
