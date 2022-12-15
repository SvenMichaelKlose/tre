(fn expr2json (x)
  (?
    (| (number? x)
       (string? x))
        x
    (symbol? x)
      {"n": (expr2json (symbol-name x))}
    (cons? x)
      {"a": (expr2json x.)
       "d": (expr2json .x)}
    (error "Illegal expression ~A." x)))

(fn json2expr (x)
  (?
    (| (number? x)
       (string? x))
        x
    (object? x)
        (?
          (ref x "n")
            (make-symbol (ref x "n"))
          (ref x "a")
            (. (ref x "a")
               (json2expr (ref x "d")))
          (error "Illegal expression."))
    (error "Illegal expression ~A." x)))
