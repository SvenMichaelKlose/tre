(def-compiler-macro cond (&rest args)
  (with-compiler-tag end-tag
    `(%block
       ,@(+@ [with-compiler-tag next
               (when _.
                 `(,@(unless (eq t _.)
                       `((%= ,*return-id* ,_.)
                         (%go-nil ,next ,*return-id*)))
                   ,@(!? (wrap-atoms ._)
                         `((%= ,*return-id* (%block ,@!))))
                   (%go ,end-tag)
                   ,@(unless (eq t _.)
                       (list next))))]
             args)
       ,end-tag
       (identity ,*return-id*))))
