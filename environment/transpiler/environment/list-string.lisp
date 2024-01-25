(fn list-string-0 (x)
  (*> #'string-concat (@ #'string x)))

(fn list-string (x)
  (*> #'string-concat (@ #'list-string-0 (group x 16384))))
