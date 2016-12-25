(defun merge (&rest x)
  (alet nil
    (@ (x (apply #'append x) !)
	  (adjoin! x !))))

(defmacro merge! (&rest x)
  `(= ,x. (merge ,@x)))
