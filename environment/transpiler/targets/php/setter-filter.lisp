; tré – Copyright (c) 2009–2014 Sven Michael Klose <pixel@copei.de>

(defun php-setter-filter (x)
  `(%= ,(php-argument-filter (%=-place x))
       ,(alet (%=-value x)
          (? (& (cons? !)
                (defined-function !.))
             `(,(compiled-function-name !.) ,@.!))
             !)))
