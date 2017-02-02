(fn %=-elt-string (val seq idx)
  (error "Cannot modify strings."))

(fn string (x)      ; TODO: PCASE…
  (?
    (string? x)     x
    (character? x)  (char-string x)
    (symbol? x)     (symbol-name x)
    (number? x)     (number-string x)
    (not x)         "NIL"))
