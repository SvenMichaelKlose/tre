;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun php-local-fun-filter (tr x)
  `(%setq ,(php-expex-argument-filter (%setq-place x))
          ,(alet (%setq-value x)
             (? (& (cons? !)
                   (transpiler-defined-function tr !.))
                `(,(compiled-function-name tr !.) ,@.!))
                !)))

(defun php-setter-filter (tr x)
  (aprog1 (php-local-fun-filter tr x)
    (transpiler-add-wanted-variable tr (%setq-place !))))
