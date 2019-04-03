(defmacro compose (&rest function-list)
  (with (rec #'((l)
                  `(,(!= l.
                       (? (& (cons? !)
                             (eq 'function !.)
                             (atom .!.))
                          .!.
                          !))
                       ,(? .l
                           (rec .l)
                           'x))))
    `#'((x)
          ,(rec function-list))))
