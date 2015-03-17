; tré – Copyright (c) 2008–2012,2014–2015 Sven Michael Klose <pixel@copei.de>

(define-tree-filter quote-keywords (x)
  (| (quote? x)
     (& (cons? x)
        (in? x. 'make-hash-table '%%%make-hash-table)))
	x
  (keyword? x) 
    `(quote ,x))
