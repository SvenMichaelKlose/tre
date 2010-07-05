;;;;; TRE environment
;;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun merge (&rest lists)
  (let result nil
    (dolist (x (apply #'nconc lists) result)
	  (adjoin! x result))))

(defmacro merge! (&rest lists)
  `(setf ,lists. (merge ,lists. ,@.lists)))
