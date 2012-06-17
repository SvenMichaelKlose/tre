;;;;; tré – Copyright (c) 2009–2012 Sven Michael Klose <pixel@copei.de>

(defun php-local-fun-filter (x)
  `(%setq ,(php-expex-argument-filter .x.)
          ,(let val ..x.
             (? (and (cons? val)
                     (transpiler-defined-function *current-transpiler* val.))
                `(,(compiled-function-name *current-transpiler* val.) ,@.val))
                val)))

(defun php-setter-filter (tr x)
  (aprog1 (php-local-fun-filter x)
    (transpiler-add-wanted-variable tr .!.)))
