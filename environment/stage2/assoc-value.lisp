;;;; TRE environment
;;;; Copyright (c) 2008,2010 Sven Klose <pixel@copei.de>

(defun assoc-value (&rest args)
  (cdr (apply #'assoc args)))

(defun (setf assoc-value) (val &rest args)
  (rplacd (apply #'assoc args) val))
