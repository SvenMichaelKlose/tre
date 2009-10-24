;;;; TRE compiler
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>

(defun compiled-list (x)
  (when x
    `(cons ,x.
           ,(compiled-list .x))))

(defun compiled-tree (x)
  (when x
	(if (consp x)
        `(cons ,(compiled-tree x.)
               ,(compiled-tree .x))
		x)))
