;;;;; tré - Copyright (c) 2008-2012 Sven Michael Klose <pixel@copei.de>

(dont-inline %error)

(defun %error (msg)
  (princ msg)
  (invoke-debugger)
  nil)

(dont-inline error)

,(? *transpiler-assert*
    '(defun error (fmt &rest args)
       (%error (+ "Error: " (apply #'format nil fmt args))))
    '(defun error (&rest args)
       (%error "Error.")))
