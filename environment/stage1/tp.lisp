; TODO: Make this a function.
(defmacro t? (&rest x)
  `(& ,@(@ [`(eq t ,_)] x)))
