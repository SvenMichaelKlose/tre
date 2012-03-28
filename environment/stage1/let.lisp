;;;;; tré - Copyright (c) 2005-2006,2008,2010-2012 Sven Michael Klose <pixel@copei.de>

;; Create new local variable.
(defmacro let (place expr &body body)
  (?
	(not body)
	  (progn
		(print place)
		(print expr)
		(print body)
	    (%error "body expected"))
    (cons? place)
	  (%error "place is not an atom")
      `(#'((,place)
			  ,@body) ,expr)))
