(fn list-string-0 (x)
  (apply #'string-concat (@ #'string x)))

(fn list-string (x)
  (apply #'string-concat (@ #'list-string-0
                            (group x 16384))))
