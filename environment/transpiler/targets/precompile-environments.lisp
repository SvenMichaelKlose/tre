;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun precompile-environments ()
  (format t "; Initializing JavaScript/ECMAScript target...~%" *boot-image*)
  (compile nil :target 'js :transpiler *js-transpiler*)
  (format t "; Initializing PHP target...~%" *boot-image*)
  (compile nil :target 'php :transpiler *php-transpiler*)
  nil)
