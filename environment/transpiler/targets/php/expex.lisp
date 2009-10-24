;;;;; TRE transpiler
;;;;; Copyright (c) 2009 Sven Klose <pixel@copei.de>

(defun php-local-fun-filter (x)
  (if
    (not (consp (third x)))
      x
    (transpiler-defined-function *php-transpiler* (first (third x)))
      `(%setq ,(second x)
       		  (,(compiled-function-name (first (third x)))
	                ,@(cdr (third x))))
    x))

(defun php-setter-filter (tr x)
  (let w/-filtered-function (php-local-fun-filter x)
    (transpiler-add-wanted-variable tr (second w/-filtered-function))
    w/-filtered-function))
