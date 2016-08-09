; tré – Copyright (c) 2008–2014,2016 Sven Michael Klose <pixel@copei.de>

(defun %error (msg)
  (princ msg)
  (invoke-debugger)
  nil)

(defun error (fmt &rest args)
  (%error (format nil "Error: ~A~%" (apply #'format nil fmt args))))
