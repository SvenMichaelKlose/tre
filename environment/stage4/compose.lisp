(defmacro compose (&rest function-list)
  (with (f [`(,(!= _.
                 (? (& (cons? !)
                       (eq 'function !.)
                       (atom .!.))
                    .!.
                    !))
               ,(? ._
                   (f ._)
                   'x))])
    `#'((x)
         ,(f function-list))))
