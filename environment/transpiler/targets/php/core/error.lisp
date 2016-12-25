; tré – Copyright (c) 2008–2009,2011–2013,2016 Sven Michael Klose <pixel@copei.de>

(defun invoke-debugger ()
  (tre_backtrace "INVOKE-DEBUGGER called"))

(defun %error (msg)
  (error_log msg)
  (%princ msg)
  (invoke-debugger))

(defun error (fmt &rest args)
  (%error (+ "Error: " (apply #'format nil fmt args))))
