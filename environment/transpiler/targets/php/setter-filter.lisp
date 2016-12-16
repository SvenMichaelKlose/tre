; tré – Copyright (c) 2009–2014,2016 Sven Michael Klose <pixel@copei.de>

(defun php-setter-filter (x)
  `(%= ,(php-argument-filter .x.)
       ,(alet ..x.
          (? (& (cons? !)
                (defined-function !.))
             `(,(compiled-function-name !.) ,@.!))
             !)))
