;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>

;; Replace elements in tree.
(defun tree-walk (tree &key ascending dont-ascend-if)
  (when (consp tree)
    (do ((i tree (cdr i)))
         ((atom i))
      (when ascending
	(funcall ascending i))
          (when (and (not (and dont-ascend-if
                               (funcall dont-ascend-if i)))
		     (consp i))
            (tree-walk (car i) :ascending ascending
			       :dont-ascend-if dont-ascend-if)))))
