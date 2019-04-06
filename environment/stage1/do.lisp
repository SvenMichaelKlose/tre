(defmacro do (binds (test &rest result) &body body)
  (let tag (gensym)
    `(block nil
       (let* ,(mapcar #'((_)
                          `(,_. ,._.))
                      binds)
         (tagbody
           ,tag
           (? ,test
              (return (progn ,@result)))
           ,@body
           ,@(mapcar #'((_)
                         (& .._. `(setq ,_. ,.._.)))
                     binds)
           (go ,tag))))))
