;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun js-function-arguments (x)
  (or (href (transpiler-function-args *js-transpiler*) x)
	  (if (builtinp x)
		  'builtin
		  (function-arguments (symbol-function x)))))
