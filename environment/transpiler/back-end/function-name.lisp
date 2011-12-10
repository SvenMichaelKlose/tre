;;;;; tré - Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun compiled-user-function-name (x)
   (make-symbol (string-concat "USERFUN_" (symbol-name x)) (symbol-package x)))

(defun compiled-function-name (tr x)
  (? (or (%transpiler-native? x)
	     (not (transpiler-defined-function tr x)))
	 x
     (compiled-user-function-name x)))

(defun compiled-function-name-string (tr name)
  (transpiler-obfuscated-symbol-string tr (compiled-function-name tr name)))
