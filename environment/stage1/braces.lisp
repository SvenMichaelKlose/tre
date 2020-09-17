(defmacro braces (&rest x)
  `(%%make-object ,@x))
