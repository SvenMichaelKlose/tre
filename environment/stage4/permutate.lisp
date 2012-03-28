;;;;; tré - Copyright (c) 2009,2012 Sven Michael Klose <pixel@copei.de>

(defun permutate-1 (head tail-permutations)
  (and head
	   (? tail-permutations
	   	  (mapcan #'((h)
		 	           (mapcar (fn (cons h (copy-list _)))
				  	           tail-permutations))
		          head)
		   (mapcar #'list head))))

(defun permutate (x)
  "Returns all combinations of elements in lists."
  (and x (permutate-1 x. (permutate .x))))
