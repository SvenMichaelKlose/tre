;;;; TRE environment
;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun find-all-if (pred &rest lists)
  (apply #'mapcan (fn when (funcall pred _)
					    (list _))
		 		  lists))
