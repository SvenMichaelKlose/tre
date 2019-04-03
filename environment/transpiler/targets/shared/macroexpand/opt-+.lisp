(fn concat-successive-strings (x)
  (& x
     (? (& (string? x.)
           (string? .x.))
        (concat-successive-strings (. (string-concat x. .x.) ..x))
        (. x. (concat-successive-strings .x)))))

(fn opt-+ (x)
  (?
    (not .x) x.
    (some #'string? x) (!= (concat-successive-strings x)
                         (? .!
                            `(string-concat ,@!)
                            !.))
    (some #'number? x) `(number+ ,@x)
    (some #'quote? x)  `(append ,@x)
    `(+ ,@x)))
