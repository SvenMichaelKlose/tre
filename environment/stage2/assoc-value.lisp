;;;; TRE environment
;;;; Copyright (c) 2008,2010-2011 Sven Klose <pixel@copei.de>

(functional assoc-value)

(defun assoc-value (&rest args)
  (cdr (apply #'assoc args)))

(defun (setf assoc-value) (val &rest args)
  (aif (apply #'assoc args)
       (rplacd ! val)
       (acons! (car args) val (cadr args))))
