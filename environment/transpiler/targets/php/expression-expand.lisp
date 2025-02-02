(fn php-argument-filter (x)
  (pcase x
    quote?   (funinfo-add-global *funinfo* (php-compiled-symbol .x.))
    keyword? (funinfo-add-global *funinfo* (php-compiled-symbol x)))
  x)

(fn php-assignment-filter (x)
  `(%= ,(php-argument-filter .x.)
       ,(!= ..x.
          (? (& (cons? !)
                (defined-function !.))
             `(,(compiled-function-name !.) ,@.!))
             !)))
