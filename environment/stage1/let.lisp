(defmacro let (place expr &body body)
  (?
    (not body)    (error "Body expected.")
    (cons? place) (error "Place ~A is not an atom." place)
    `(#'((,place)
          ,@body) ,expr)))
