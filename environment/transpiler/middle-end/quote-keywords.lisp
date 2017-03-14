(define-tree-filter quote-keywords (x)
  (| (quote? x)
     (& (cons? x)
        (in? x. 'make-hash-table '%%%make-object)))
	x
  (keyword? x) 
    `(quote ,x))
