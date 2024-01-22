(defmacro do (vars (test &rest result) &body body)
  (let tag (gensym)
    `(block nil
       (let* ,(mapcar [`(,_. ,._.)]
                      vars)
         (tagbody
           ,tag
           (? ,test
              (return (progn
                        ,@result)))
           ,@body
           ,@(mapcar [& .._.
                        `(setq ,_. ,.._.)]
                      vars)
           (go ,tag))))))
