;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun compiled-user-function-name (x)
  (!? (transpiler-function-name-prefix *transpiler*)
      (make-symbol (string-concat ! (symbol-name x)) (symbol-package x))
      x))

(defun compiled-function-name (tr x)
  (? (| (%transpiler-native? x)
	    (not (transpiler-defined-function tr x)))
	 x
     (compiled-user-function-name x)))

(defun compiled-function-name-string (tr name)
  (transpiler-obfuscated-symbol-string tr (compiled-function-name tr name)))
