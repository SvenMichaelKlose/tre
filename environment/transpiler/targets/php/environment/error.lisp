;;;;; tré - Copyright (c) 2008-2009,2011-2012 Sven Michael Klose <pixel@copei.de>

(dont-obfuscate exit)

(defun invoke-native-debugger ()
  (header "HTTP/1.0 404")
  (print_r *_request*)
  (princ "<p>No native debugger - program exits.</p>")
  (%setq nil (exit))
  nil)

(dont-inline %error)

(defun %error (msg)
  (princ msg)
  (invoke-native-debugger))

(dont-inline error)

,(? *transpiler-assert*
    '(defun error (fmt &rest args)
       (%error (+ "Error :" (apply #'format nil fmt args))))
    '(defun error (fmt &rest args)))
