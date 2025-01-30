(fn php-assignment-filter (x)
  `(%= ,(php-argument-filter .x.)
       ,(!= ..x.
          (? (& (cons? !)
                (defined-function !.))
             `(,(compiled-function-name !.) ,@.!))
             !)))
