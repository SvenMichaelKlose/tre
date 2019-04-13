(defmacro braces (&rest x)
  (? (| (not x)
        (string? x.)
        (keyword? x.))
     `(%%make-object ,@x)
     `(progn ,@x)))

(defmacro curly (&rest x)
  `(braces ,@x))
