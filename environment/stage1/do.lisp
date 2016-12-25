(defmacro do (binds (test &rest result) &body body)
  (let tag (gensym)
    `(block nil
       (let* ,(@ [`(,_. ,._.)] binds)
         (tagbody
           ,tag
           (? ,test
              (return {,@result}))
           ,@body
           ,@(@ [& .._. `(setq ,_. ,.._.)] binds)
           (go ,tag))))))
