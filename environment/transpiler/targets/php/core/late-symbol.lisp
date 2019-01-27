(fn make-symbol (x &optional (pkg nil))
  (symbol x pkg))

(fn make-package (x)
  (symbol x nil))

(fn symbol-name (x)
  (?
    (eq t x)  "T"
    x         (? (symbol? x)
                 x.n
                 {(print x)
                  (error "Symbol expected.")})
    "NIL"))

(fn symbol-value (x)
  (?
    (eq t x)  t
    (x.v)))

(fn symbol-function (x)
  (?
    (eq t x)  nil
    x         (x.f)))

(fn symbol-package (x)
  (?
    (not x)   nil
    (eq t x)  nil
    x.p))

(fn symbol? (x)
  (| (not x)
     (eq t x)
     (is_a x "__symbol")))
