;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun php-setter-filter (x)
  `(%= ,(php-argument-filter (%=-place x))
       ,(alet (%=-value x)
          (? (& (cons? !)
                (transpiler-defined-function *transpiler* !.))
             `(,(compiled-function-name !.) ,@.!))
             !)))
