;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

(define-tree-filter transpiler-quote-keywords (x)
  (or (%quote? x)
   	  (and (consp x)
     	   (eq 'make-hash-table (car x))))
	x
  (keywordp x) 
    `(%quote ,x))
