;;;; TRE environment
;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defmacro def-head-predicate (sym)
  `(defun ,($ sym '?) (x)
     (and (consp x)
	      (eq ',sym x.))))
