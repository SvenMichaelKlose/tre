(fn string-integer (str)
  (!= (make-string-stream)
    (princ ! str)
    (read-integer !)))
