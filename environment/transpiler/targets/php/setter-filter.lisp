(fn php-setter-filter (x)
  `(%= ,(php-argument-filter .x.)
       ,(alet ..x.
          (? (& (cons? !)
                (defined-function !.))
             `(,(compiled-function-name !.) ,@.!))
             !)))
