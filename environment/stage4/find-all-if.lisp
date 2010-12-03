;;;; TRE environment
;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun find-all-if (pred &rest lists)
  (apply #'remove-if (fn not (funcall pred _))
		 		  lists))
