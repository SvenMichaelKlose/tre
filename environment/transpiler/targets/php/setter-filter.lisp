;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun php-setter-filter (x)
  `(%setq ,(php-argument-filter (%setq-place x))
          ,(alet (%setq-value x)
             (? (& (cons? !)
                   (transpiler-defined-function *transpiler* !.))
                `(,(compiled-function-name !.) ,@.!))
                !)))
