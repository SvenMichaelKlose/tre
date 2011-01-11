;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2009,2011 Sven Klose <pixel@copei.de>

(dont-inline %error)

(defun %error (msg)
  (princ msg)
  (invoke-native-debugger))

(dont-inline error)

(defun error (fmt &rest args)
  (princ (+ "Error :" (apply #'format nil fmt args)))
  (invoke-native-debugger))
