;;;;; tré – Copyright (c) 2005–2007,2012 Sven Michael Klose <pixel@copei.de>

;; Replace elements in tree.
(defun tree-walk (i &key (ascending nil) (dont-ascend-if nil) (dont-ascend-after-if nil))
  (? (atom i)
	 (funcall ascending i)
	 (with (y i.
		    a (| (& dont-ascend-if (funcall dont-ascend-if y) y)
				 (? (& dont-ascend-after-if (funcall dont-ascend-after-if y))
					(funcall ascending y)
	  			    (tree-walk (? ascending
					 	 		  (funcall ascending y)
					 	 		  y)
					 		   :ascending ascending
					 		   :dont-ascend-if dont-ascend-if
					 		   :dont-ascend-after-if dont-ascend-after-if))))
	  (cons a (tree-walk .i :ascending ascending
						    :dont-ascend-if dont-ascend-if
						    :dont-ascend-after-if dont-ascend-after-if)))))
