;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun compiled-user-function-name (x)
  (make-symbol (string-concat (transpiler-function-name-prefix *current-transpiler*) (symbol-name x)) (symbol-package x)))

(defun compiled-function-name (tr x)
  (? (| (%transpiler-native? x)
	    (not (transpiler-defined-function tr x)))
	 x
     (compiled-user-function-name x)))

(defun compiled-function-name-string (tr name)
  (transpiler-obfuscated-symbol-string tr (compiled-function-name tr name)))
