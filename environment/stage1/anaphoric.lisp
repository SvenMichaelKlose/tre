;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006,2008 Sven Klose <pixel@copei.de>

(defmacro aif (predicate consequence &optional alternative)
  `(let ! ,predicate
     (if !
		 ,consequence
		 ,alternative)))

(defmacro awhen (predicate &rest body)
  `(let ! ,predicate
     (when !
	   ,@body)))

(defmacro anif (name predicate consequence &optional alternative)
  `(let ,name ,predicate
     (if ,name
		 ,consequence
		 ,alternative)))

(defmacro anwhen (name predicate &rest body)
  `(let ,name ,predicate
     (when ,name
	   ,@body)))

; XXX tests missing
