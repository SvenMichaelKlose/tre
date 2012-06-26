;;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun merge (&rest lists)
  (let result nil
    (dolist (x (apply #'nconc lists) result)
	  (adjoin! x result))))

(defmacro merge! (&rest lists)
  `(= ,lists. (merge ,lists. ,@.lists)))
