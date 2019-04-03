(fn php-setter-filter (x)
  `(%= ,(php-argument-filter .x.)
       ,(!= ..x.
          (? (& (cons? !)
                (defined-function !.))
             `(,(compiled-function-name !.) ,@.!))
             !)))
