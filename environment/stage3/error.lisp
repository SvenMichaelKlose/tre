;;;; TRE environment
;;;; Copyright (c) 2006-2008,2011 Sven Klose <pixel@copei.de>

(defun error (&rest args)
  (%error (apply #'format nil args)))

(defun warn (&rest args)
  (apply #'format t (string-concat "WARNING: " (car args)) (cdr args)))
