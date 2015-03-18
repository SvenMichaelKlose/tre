; tré – Copyright (c) 2009,2011–2012,2015 Sven Michael Klose <pixel@copei.de>

(defmacro def-head-predicate (sym)
  `(defun ,($ sym '?) (x)
     (& (cons? x)
	    (eq ',sym x.)
        x)))
