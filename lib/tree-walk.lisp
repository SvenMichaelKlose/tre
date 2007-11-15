;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>

;; Replace elements in tree.
(defun tree-walk (i &key (ascending nil) (dont-ascend-if nil))
  (if (atom i)
	i
	(with (a (if (and dont-ascend-if (funcall dont-ascend-if (car i)))
				 (car i)
	  			 (tree-walk
					 (if ascending
					 	 (funcall ascending (car i))
					 	 (car i))
					 :ascending ascending :dont-ascend-if dont-ascend-if)))
	  (cons a
	  		(tree-walk (cdr i) :ascending ascending :dont-ascend-if dont-ascend-if)))))
