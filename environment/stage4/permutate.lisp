;;;;; tré – Copyright (c) 2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(defun permutate-1 (head tail-permutations)
  (& head
	 (!? tail-permutations
	     (mapcan #'((h)
	 	              (mapcar [cons h (copy-list _)] !))
		         head)
		(mapcar #'list head))))

(defun permutate (x)
  (& x (permutate-1 x. (permutate .x))))
