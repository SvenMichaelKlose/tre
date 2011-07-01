;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(dont-inline %error)

(defun %error (msg)
  (alert msg)
  (invoke-native-debugger))

(dont-inline error)

,(? *transpiler-log*
    '(defun error (fmt &rest args)
       (%error (+ "Error :" (apply #'format nil fmt args))))
    '(defun error (&rest args)))
