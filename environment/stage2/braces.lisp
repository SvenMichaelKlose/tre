(defmacro braces (&rest x)
  `(%%%make-json-object ,@x))
