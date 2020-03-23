(defmacro with-temporary (place val &body body)
  (with-gensym old-val
    `(with (,old-val ,place)
       (= ,place ,val)
       (prog1
         (progn
           ,@body)
         (= ,place ,old-val)))))

(defmacro with-temporaries (lst &body body)
  (| lst (error "Assignment list expected."))
  `(with-temporary ,lst. ,.lst.
     ,@(? ..lst
          `((with-temporaries ,..lst ,@body))
          body)))
