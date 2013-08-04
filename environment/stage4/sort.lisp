;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun sort-divide (x left right test<)
  (with (i     left
		 j     (integer-- right)
		 pivot (elt x right))
    (while (integer< i j)
		   nil
	  (while (& (integer< i right)
                (not (funcall test< pivot (elt x i))))
			 nil
	    (integer++! i))
	  (while (& (integer> j left)
                (funcall test< pivot (elt x j)))
			 nil
		(integer--! j))
	  (& (integer< i j)
         (xchg (elt x i) (elt x j))))
	(& (funcall test< pivot (elt x i))
       (xchg (elt x i) (elt x right)))
	i))

(defun sort-0 (x left right test<)
  (when (integer< left right)
	(let divisor (sort-divide x left right test<)
	  (sort-0 x left (integer-- divisor) test<)
	  (sort-0 x (integer++ divisor) right test<))))

(defun sort (x &key (test #'<))
  (& x (sort-0 x 0 (integer-- (length x)) test))
  x)
