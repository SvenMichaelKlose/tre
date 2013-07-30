;;;;; tré – Copyright (c) 2005-2006,2008,2010–2013 Sven Michael Klose <pixel@copei.de>

(defmacro let (place expr &body body)
  (?
	(not body)    (error "Body expected.")
    (cons? place) (error "Place ~A is not an atom." place)
    `(#'((,place)
          ,@body) ,expr)))
