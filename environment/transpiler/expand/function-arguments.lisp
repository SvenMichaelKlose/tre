;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun current-transpiler-function-arguments-w/o-builtins (x)
  (or (href (transpiler-function-args *current-transpiler*) x)
	  (if (builtinp x)
		  'builtin
		  (function-arguments (symbol-function x)))))
