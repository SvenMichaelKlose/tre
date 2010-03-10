;;;;; TRE environment
;;;;; Copyright (c) 2005-2006,2008,2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; LET macro

;; Create new local variable.
(defmacro let (place expr &rest body)
  (if
	(not body)
	  (%error "body expected")
    (consp place)
	  (%error "place is not an atom")
      `(#'((,place)
			  ,@body) ,expr)))
