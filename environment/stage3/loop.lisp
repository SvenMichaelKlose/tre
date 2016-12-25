(defmacro loop (&body body)
  (let tag (gensym)
    `(block nil
        (tagbody
          ,tag
          ,@body
          (go ,tag)))))
