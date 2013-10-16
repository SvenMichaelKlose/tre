;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun compiled-function-name (name)
  (make-symbol (+ (transpiler-function-name-prefix *transpiler*) (symbol-name name)) (symbol-package name)))

(defun compiled-function-name-string (name)
  (obfuscated-identifier (compiled-function-name name)))
