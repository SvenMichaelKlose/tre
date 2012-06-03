;;;;; tré - Copyright (c) 2008-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate exit)

(defun invoke-debugger ()
  (tre_backtrace "INVOKE-DEBUGGER called"))

(dont-inline %error)

(defun %error (msg)
  (princ msg)
  (invoke-debugger))

(dont-inline error)

,(? *transpiler-assert*
    '(defun error (fmt &rest args)
       (%error (+ "Error :" (apply #'format nil fmt args))))
    '(defun error (fmt &rest args)))
