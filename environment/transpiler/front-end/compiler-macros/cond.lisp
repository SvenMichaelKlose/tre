(def-compiler-macro cond (&rest args)
  (with-compiler-tag end-tag
    `(%block
       ,@(+@ [with-compiler-tag next
               (when _.
                 `(,@(unless (eq t _.)
                       `((%= ,*return-symbol* ,_.)
                         (%go-nil ,next ,*return-symbol*)))
                   ,@(!? (wrap-atoms ._)
                         `((%= ,*return-symbol* (%block ,@!))))
                   (%go ,end-tag)
                   ,@(unless (eq t _.)
                       (list next))))]
             args)
       ,end-tag
       (identity ,*return-symbol*))))
