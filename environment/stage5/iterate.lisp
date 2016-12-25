(defmacro iterate (iterator step init result &body body)
  (with-gensym next
    `(with (,iterator ,init
            ,next nil)
       (while ,iterator
              ,result
         (= ,next ,step)
         ,@body
         (= ,iterator ,next)))))
