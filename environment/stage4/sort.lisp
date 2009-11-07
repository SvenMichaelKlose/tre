;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pisel@copei.de>

(defun sort-divide (x left right)
  (with (i left
		 j (1- right)
		 pivot (elt x right))
    (while (< i j)
		   nil
	  (while (and (<= (elt x i) pivot)
				  (< i right))
			 nil
	    (1+! i))
	  (while (and (>= (elt x j) pivot)
				  (> j left))
			 nil
		(1-! j))
	  (when (< i j)
		(xchg (elt x i) (elt x j))
		(1+! i)
		(1-! j)))
	(when (< pivot (elt x i))
	  (xchg (elt x i) (elt x right)))
	i))

(defun sort-0 (x left right)
  (when (< left right)
	(let divisor (sort-divide x left right)
	  (sort-0 x left (1- divisor))
	  (sort-0 x (1+ divisor) right))))

(defun sort (x)
  (sort-0 x 0 (1- (length x)))
  x)
