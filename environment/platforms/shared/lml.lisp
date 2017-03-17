(fn string-or-cons? (expr)
  (| (string? expr) (cons? expr)))

(fn lml-attr-string (x)
  (| (keyword? x)
     (error "LML attribute keyword expected instead of ~A." x))
  (downcase (symbol-name x)))
