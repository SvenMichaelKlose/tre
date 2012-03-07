;;;; tré - Copyright (c) 2005-2006,2008-2012 Sven Michael Klose <pixel@copei.de>

(defmacro aif (predicate &body alternatives)
  (if alternatives
   `(let ! ,predicate
      (if !
		  ,(car alternatives)
		  (aif ,@(cdr alternatives))))
   predicate))

(defmacro awhen (predicate &body body)
  `(let ! ,predicate
     (when !
	   ,@body)))

(defmacro alet (obj &body body)
  `(let ! ,obj
	 ,@body))

(defmacro aprog1 (obj &body body)
  `(let ! ,obj
	 ,@body
	 !))

(defmacro adolist ((seq &optional (result nil)) &body body)
  `(dolist (! ,seq ,result)
     ,@body))

; XXX tests missing
