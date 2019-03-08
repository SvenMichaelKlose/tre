(fn lml-attr? (x)
  (& (cons? x)
     (cons? .x)
     (keyword? x.)))

(fn lml-symbol-string (x)
  (list-string (camel-notation (string-list (symbol-name x)))))

(fn lml-attr-string (x)
  (| (keyword? x)
     (error "LML attribute keyword expected instead of ~A." x))
  (lml-symbol-string x))
