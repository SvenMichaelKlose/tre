;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

(defun %error (msg)
  (log msg))

(defun error (fmt &rest args)
  (format *standard-log* "<b>Error:</b>")
  (apply #'format *standard-log* fmt args)
  (terpri *standard-log*)
  (inoke-native-debugger))
