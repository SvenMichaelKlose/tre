;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(define-tree-filter transpiler-quote-keywords (x)
  (or (%quote? x)
   	  (and (cons? x)
     	   (in? x. 'make-hash-table '%%%make-hash-table)))
	x
  (keyword? x) 
    `(%quote ,x))
