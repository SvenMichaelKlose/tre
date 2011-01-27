;;;; TRE compiler
;;;; Copyright (c) 2005-2009,2011 Sven Klose <pixel@copei.de>

(defun compiled-list (x)
  (? (cons? x)
     `(cons ,x.
            ,(compiled-list .x))
	 x))

(defun compiled-tree (x)
  (? (cons? x)
     `(cons ,(compiled-tree x.)
            ,(compiled-tree .x))
	 x))
