;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2010-2011 Sven Klose <pixel@copei.de>

(defun string-concat-successive-literals-0 (x y)
  (if
	(not x)
	  (awhen y
	    (list !))
	(not x.)
	  (string-concat-successive-literals-0 .x nil)
	(string? x.)
   	  (if y
		  (string-concat-successive-literals-0 .x (string-concat y x.))
   	  	  (string-concat-successive-literals-0 .x x.))
	y
	  (cons y (cons x. (string-concat-successive-literals-0 .x nil)))
	(cons x. (string-concat-successive-literals-0 .x nil))))

(defun string-concat-successive-literals (x)
  (string-concat-successive-literals-0 x nil))
