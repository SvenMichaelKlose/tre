;;;;; TRE transpiler
;;;;; Copyright (c) 2009-2011 Sven Klose <pixel@copei.de>

(defun php-local-fun-filter (x)
  `(%setq ,(php-expex-filter .x.)
          ,(let val ..x.
             (? (and (cons? val)
                     (transpiler-defined-function *php-transpiler* val.))
                `(,(compiled-function-name val.) ,@.val))
                val)))

(defun php-setter-filter (tr x)
  (aprog1 (php-local-fun-filter x)
    (transpiler-add-wanted-variable tr .!.)))
