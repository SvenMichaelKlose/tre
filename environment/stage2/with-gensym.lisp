;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2006 Sven Klose <pixel@copei.de>

(defmacro with-gensym (q &rest body)
  `(let (,@(mapcar #'(lambda (x) `(,x (gensym))) 
		   (if (consp q) q (list q))))
     ,@body))
