(define-tree-filter quote-keywords (x)
  (quote? x)
    x
  (keyword? x) 
    `(quote ,x))
