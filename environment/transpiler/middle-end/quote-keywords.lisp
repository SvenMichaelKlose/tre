(define-tree-filter quote-keywords (x)
  (| (quote? x)
     (& (cons? x)
        (in? x. 'make-hash-table '%%%make-hash-table)))
	x
  (keyword? x) 
    `(quote ,x))
