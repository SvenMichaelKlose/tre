;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defun precompile-environments ()
  (format t "; Initializing JavaScript/ECMAScript target...~%" *boot-image*)
  (with-temporary (transpiler-import-from-environment? *js-transpiler*) nil
    (compile nil :target 'js :transpiler *js-transpiler*))
  (format t "; Initializing PHP target...~%" *boot-image*)
  (with-temporary (transpiler-import-from-environment? *php-transpiler*) nil
  (compile nil :target 'php :transpiler *php-transpiler*))
  nil)
