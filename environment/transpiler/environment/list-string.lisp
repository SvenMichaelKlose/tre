(fn list-string-0 (x)
  (apply #'string-concat (mapcar #'string x)))

(fn list-string (x)
  (apply #'string-concat (mapcar #'list-string-0 (group x 16384))))
