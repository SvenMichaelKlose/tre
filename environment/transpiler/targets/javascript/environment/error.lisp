;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defun %error (msg)
  (princ msg)
  (invoke-debugger)
  nil)

(defun error (fmt &rest args)
  (!? *backtrace*
      (format *standard-error* "; In scope ~A:~%" *backtrace*))
  (%error (+ "Error: " (apply #'format nil fmt args))))
