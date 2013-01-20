;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun php-local-fun-filter (x)
  (let tr *transpiler*
    `(%setq ,(php-expex-argument-filter .x.)
            ,(let val ..x.
               (? (& (cons? val) (transpiler-defined-function tr val.))
                  `(,(compiled-function-name tr val.) ,@.val))
                  val))))

(defun php-setter-filter (tr x)
  (aprog1 (php-local-fun-filter x)
    (transpiler-add-wanted-variable tr .!.)))
