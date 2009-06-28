;;;; TRE environment
;;;; Copyright (c) 2005-2006,2008-2009 Sven Klose <pixel@copei.de>

;tredoc
; "Like IF but stores the result of the predicate in new local variable !."
; (courtesy-of onlisp)
; (see-also if)
(defmacro aif (predicate consequence &optional alternative)
  `(let ! ,predicate
     (if !
		 ,consequence
		 ,alternative)))

; "Like WHEN but stores the result of the predicate in new local variable !."
; (courtesy-of onlisp)
; (see-also when)
(defmacro awhen (predicate &rest body)
  `(let ! ,predicate
     (when !
	   ,@body)))

; "Like IF but stores the result of the predicate in a new local variable."
; (arg name "Name of the new local variable.")
; (courtesy-of onlisp)
; (see-also if)
(defmacro anif (name predicate consequence &optional alternative)
  `(let ,name ,predicate
     (if ,name
		 ,consequence
		 ,alternative)))

; "Like WHEN but stores the result of the predicate in a new local variable."
; (arg name "Name of the new local variable.")
; (courtesy-of onlisp)
; (see-also when)
(defmacro anwhen (name predicate &rest body)
  `(let ,name ,predicate
     (when ,name
	   ,@body)))

; XXX tests missing
