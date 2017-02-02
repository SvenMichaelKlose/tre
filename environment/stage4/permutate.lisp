(fn permutate-1 (head tail-permutations)
  (& head
	 (!? tail-permutations
	     (mapcan #'((h)
	 	             (@ [. h (copy-list _)] !))
		         head)
		 (@ #'list head))))

(fn permutate (x)
  (& x (permutate-1 x. (permutate .x))))
