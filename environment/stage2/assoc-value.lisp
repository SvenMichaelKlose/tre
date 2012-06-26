;;;;; tré – Copyright (c) 2008,2010–2012 Sven Michael Klose <pixel@copei.de>

(functional assoc-value)

(defun assoc-value (&rest args)
  (cdr (apply #'assoc args)))

(defun (= assoc-value) (val &rest args)
  (!? (apply #'assoc args)
      (rplacd ! val)
      (acons! (car args) val (cadr args))))
