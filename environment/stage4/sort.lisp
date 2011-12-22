;;;;; tré - Copyright (c) 2009-2011 Sven Klose <pisel@copei.de>

(defun sort-divide (x left right test<)
  (with (i left
		 j (integer-1- right)
		 pivot (elt x right))
    (while (integer< i j)
		   nil
	  (while (and (integer< i right)
                  (not (funcall test< pivot (elt x i))))
			 nil
	    (integer1+! i))
	  (while (and (integer> j left)
                  (funcall test< pivot (elt x j)))
			 nil
		(integer1-! j))
	  (when (integer< i j)
		(xchg (elt x i) (elt x j))))
	(when (funcall test< pivot (elt x i))
	  (xchg (elt x i) (elt x right)))
	i))

(defun sort-0 (x left right test<)
  (when (integer< left right)
	(let divisor (sort-divide x left right test<)
	  (sort-0 x left (integer-1- divisor) test<)
	  (sort-0 x (integer-1+ divisor) right test<))))

(defun sort (x &key (test #'<))
  (when x
    (sort-0 x 0 (integer-1- (length x)) test)
    x))
