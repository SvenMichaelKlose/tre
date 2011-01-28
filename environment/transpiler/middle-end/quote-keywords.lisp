;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(define-tree-filter transpiler-quote-keywords (x)
  (or (%quote? x)
   	  (and (cons? x)
     	   (eq 'make-hash-table x.)))
	x
  (keyword? x) 
    `(%quote ,x))
