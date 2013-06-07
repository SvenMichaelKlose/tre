;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun compiled-function-name (tr name)
  (make-symbol (+ (transpiler-function-name-prefix tr) (symbol-name name)) (symbol-package name)))

(defun compiled-function-name-string (tr name)
  (transpiler-obfuscated-symbol-string tr (compiled-function-name tr name)))
