(defun sort-divide (x left right test<)
  (with (i     left
		 j     (-- right)
		 pivot (elt x right))
    (while (< i j)
		   nil
	  (while (& (< i right)
                (not (funcall test< pivot (elt x i))))
			 nil
	    (++! i))
	  (while (& (> j left)
                (funcall test< pivot (elt x j)))
			 nil
		(--! j))
	  (& (< i j)
         (xchg (elt x i) (elt x j))))
	(& (funcall test< pivot (elt x i))
       (xchg (elt x i) (elt x right)))
	i))

(defun sort-0 (x left right test<)
  (when (< left right)
	(let divisor (sort-divide x left right test<)
	  (sort-0 x left (-- divisor) test<)
	  (sort-0 x (++ divisor) right test<))))

(defun sort (x &key (test #'<))
  (& x (sort-0 x 0 (-- (length x)) test))
  x)
