;;;; TRE environment
;;;; Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defmacro def-head-predicate (sym)
  `(defun ,($ sym '?) (x)
     (and (cons? x)
	      (eq ',sym x.))))
