;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2010 Sven Klose <pixel@copei.de>

(defmacro aif (predicate &rest alternatives)
  (if alternatives
   `(let ! ,predicate
      (if !
		  ,(car alternatives)
		  (aif ,@(cdr alternatives))))
   predicate))

(defmacro awhen (predicate &rest body)
  `(let ! ,predicate
     (when !
	   ,@body)))

(defmacro alet (obj &rest body)
  `(let ! ,obj
	 ,@body))

(defmacro aprog1 (obj &rest body)
  `(let ! ,obj
	 ,@body
	 !))

; XXX tests missing
