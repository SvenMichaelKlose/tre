(defmacro braces (&rest x)
  `(%make-json-object
     ,@(+@ [… (? (keyword? _.)
                 (convert-identifier _.)
                 _.)
              ._.]
           (group x 2))))
