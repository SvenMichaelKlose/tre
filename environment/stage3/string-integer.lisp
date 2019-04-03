(fn string-integer (str)
  (!= (make-string-stream)
    (format ! "~A" str)
    (read-integer !)))
