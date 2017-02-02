(fn wrap-atom (x)
  (? (& (atom x)
        (not (number? x)))
     `(identity ,x)
     x))

(define-filter wrap-atoms #'wrap-atom)
