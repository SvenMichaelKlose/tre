;;;;; TRE transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>

;; Put keywords into %QUOTE-expressions, so they can be recognized
;; as symbols during code-generation.
(defun transpiler-quote-keywords (x)
  (if (or (%quote? x)
    	  (and (consp x)
	     	   (eq 'make-hash-table (car x))))
	  x
	  (if
    	(keywordp x)  `(%quote ,x)
		(consp x)	  (traverse #'transpiler-quote-keywords x)
		x)))
