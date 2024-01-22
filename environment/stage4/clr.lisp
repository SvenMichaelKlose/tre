(defmacro clr (&rest places)
  `(= ,@(+@ [list _ nil]
            places)))
