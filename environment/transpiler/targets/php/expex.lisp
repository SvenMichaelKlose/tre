;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun php-local-fun-filter (x)
  `(%setq ,(php-argument-filter (%setq-place x))
          ,(alet (%setq-value x)
             (? (& (cons? !)
                   (transpiler-defined-function *transpiler* !.))
                `(,(compiled-function-name !.) ,@.!))
                !)))

(defun php-setter-filter (x)
  (aprog1 (php-local-fun-filter x)
    (transpiler-add-wanted-variable *transpiler* (%setq-place !))))
