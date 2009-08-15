;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun %error (msg)
  (alert msg)
  (inoke-native-debugger))

(defun error (fmt &rest args)
  (alert (+ "Error :" (apply #'format nil fmt args)))
  (terpri *standard-log*)
  (inoke-native-debugger))
