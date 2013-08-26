;;;;; tré – Copyright (c) 2008–2009,2011–2013 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate exit)

(defun invoke-debugger ()
  (tre_backtrace "INVOKE-DEBUGGER called"))

(defun %error (msg)
  (princ msg)
  (invoke-debugger))

(defun error (fmt &rest args)
  (%error (+ "Error: " (apply #'format nil fmt args))))
