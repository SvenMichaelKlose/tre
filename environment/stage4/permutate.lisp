; tré – Copyright (c) 2009,2012–2015 Sven Michael Klose <pixel@hugbox.org>

(defun permutate-1 (head tail-permutations)
  (& head
	 (!? tail-permutations
	     (mapcan #'((h)
	 	             (@ [. h (copy-list _)] !))
		         head)
		 (@ #'list head))))

(defun permutate (x)
  (& x (permutate-1 x. (permutate .x))))
