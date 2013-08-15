;;;;; tré – Copyright (c) 2010,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun merge (&rest lists)
  (let result nil
    (dolist (x (apply #'append lists) result)
	  (adjoin! x result))))

(defmacro merge! (&rest lists)
  `(= ,lists. (merge ,lists. ,@.lists)))
