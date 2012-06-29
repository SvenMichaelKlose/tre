;;;;; tré – Copyright (c) 2008–2012 Sven Klose <pixel@copei.de>

(define-tree-filter transpiler-quote-keywords (x)
  (| (%quote? x)
     (& (cons? x) (in? x. 'make-hash-table '%%%make-hash-table)))
	x
  (keyword? x) 
    `(%quote ,x))
