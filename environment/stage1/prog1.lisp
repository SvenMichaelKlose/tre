(defmacro prog1 (&body body)
  (alet (gensym)
    `(let ,! ,body.
      ,@.body
      ,!)))
