(defmacro clr (&rest places)
  `(= ,@(mapcan [`(,_ nil)] places)))
