;;;; TRE compiler
;;;; Copyright (c) 2005-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; Miscellaneous utilities.

(defun print-symbols (forms)
  (dolist (i forms)
    (verbose " ~A" (symbol-name i))))

(defun compiled-list (x)
  (when x
    `(cons ,x.
           ,(compiled-list .x))))

(defun compiled-tree-0 (x)
  (when x
	(if (consp x)
        `(cons ,(compiled-tree-0 x.)
               ,(compiled-tree-0 .x))
		x)))

(defun compiled-tree (x)
  (print x)
  (print (compiled-tree-0 x))
  (print (compiled-list x)))
