;;;;; TRE environment
;;;;; Copyright (c) 2009 Sven Klose <pisel@copei.de>

(defun sort-divide (x left right test)
  (with (i left
		 j (1- right)
		 pivot (elt x right))
    (while (< i j)
		   nil
	  (while (and (funcall test (elt x i) pivot)
				  (< i right))
			 nil
	    (1+! i))
	  (while (and (funcall test pivot (elt x j))
				  (> j left))
			 nil
		(1-! j))
	  (when (< i j)
		(xchg (elt x i) (elt x j))
		(1+! i)
		(1-! j)))
	(when (funcall test pivot (elt x i))
	  (xchg (elt x i) (elt x right)))
	i))

(defun sort-0 (x left right test)
  (when (< left right)
	(let divisor (sort-divide x left right test)
	  (sort-0 x left (1- divisor) test)
	  (sort-0 x (1+ divisor) right test))))

(defun sort (x &key (test #'<=))
  (sort-0 x 0 (1- (length x)) test)
  x)
