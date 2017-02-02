(fn merge (&rest x)
  (alet nil
    (@ (x (apply #'append x) !)
	  (adjoin! x !))))

(defmacro merge! (&rest x) ; TODO: Remove.
  `(= ,x. (merge ,@x)))
