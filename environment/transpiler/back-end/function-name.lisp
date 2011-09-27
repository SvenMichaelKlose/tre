;;;;; tré - Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun compiled-function-name (x)
  (? (or (%transpiler-native? x)
	     (not (transpiler-defined-function *current-transpiler* x)))
	 x
     (make-symbol (string-concat "USERFUN_" (symbol-name x)) (symbol-package x))))
