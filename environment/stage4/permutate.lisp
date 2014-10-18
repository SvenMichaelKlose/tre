;;;;; tré – Copyright (c) 2009,2012–2014 Sven Michael Klose <pixel@hugbox.org>

(defun permutate-1 (head tail-permutations)
  (& head
	 (!? tail-permutations
	     (mapcan #'((h)
	 	              (filter [. h (copy-list _)] !))
		         head)
		(filter #'list head))))

(defun permutate (x)
  (& x (permutate-1 x. (permutate .x))))
