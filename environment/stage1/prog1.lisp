(defmacro prog1 (&body body)
  (#'((!)
        `(#'((,!)
               ,@.body
               ,!)
             ,body.))
       (gensym)))
