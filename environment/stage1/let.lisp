;;;;; tré – Copyright (c) 2005-2006,2008,2010–2013 Sven Michael Klose <pixel@copei.de>

;; Create new local variable.
(defmacro let (place expr &body body)
  (?
	(not body)
	  (progn
		(print place)
		(print expr)
		(print body)
	    (%error "Body expected."))
    (cons? place)
	  (progn
        (print place)
	    (%error "Place is not an atom."))
    `(#'((,place)
          ,@body) ,expr)))
