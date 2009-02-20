;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun assoc-value (&rest args)
  (cdr (apply #'assoc args)))
