(defmacro prog1 (&body body)
  (!= (gensym)
    `(let ,! ,body.
      ,@.body
      ,!)))
