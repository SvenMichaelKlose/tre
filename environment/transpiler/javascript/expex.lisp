;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun js-setter-filter (tr x)
  (transpiler-add-wanted-variable tr (second x))
  x)

(defun js-expand-literals (x)
  (if
    (atom x)
     (if (expex-global-variable? x)
	     (transpiler-add-wanted-variable *js-transpiler* x)
         x)
	(transpiler-import-from-expex x)))

(defun js-function-arguments (x)
  (or (href (transpiler-function-args *js-transpiler*) x)
	  (if (builtinp x)
		  'builtin
		  (function-arguments (symbol-function x)))))
