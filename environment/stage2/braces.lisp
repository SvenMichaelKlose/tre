(defmacro braces (&rest x)
  `(make-json-object
     ,@(+@ [… (? (keyword? _.)
                 (convert-identifier-r _.)
                 _.)
              ._.]
           (group x 2))))
