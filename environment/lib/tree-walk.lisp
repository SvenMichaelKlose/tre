;;;; TRE environment
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>

;; Replace elements in tree.
(defun tree-walk (i &key (ascending nil) (dont-ascend-if nil) (dont-ascend-after-if nil))
  (if (atom i)
	(funcall ascending i)
	(with (y (car i)
		   a (if (and dont-ascend-if
				      (funcall dont-ascend-if y))
				 y
				 (if (and dont-ascend-after-if
						  (funcall dont-ascend-after-if y))
					 (funcall ascending y)
	  			     (tree-walk (if ascending
					 	 		    (funcall ascending y)
					 	 		    y)
					 		    :ascending ascending
					 		    :dont-ascend-if dont-ascend-if
					 		    :dont-ascend-after-if dont-ascend-after-if))))
	  (cons a
	  		(tree-walk (cdr i) :ascending ascending
							   :dont-ascend-if dont-ascend-if
							   :dont-ascend-after-if dont-ascend-after-if)))))
