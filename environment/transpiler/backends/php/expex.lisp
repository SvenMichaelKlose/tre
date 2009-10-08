;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun php-setter-filter (tr x)
  (transpiler-add-wanted-variable tr (second x))
  x)

(defun php-expand-literals (x)
  (if
    (atom x)
     (if (expex-global-variable? x)
	     (transpiler-add-wanted-variable *php-transpiler* x)
         x)
	(transpiler-import-from-expex x)))

(defun php-function-arguments (x)
  (or (href (transpiler-function-args *php-transpiler*) x)
	  (if (builtinp x)
		  'builtin
		  (function-arguments (symbol-function x)))))
