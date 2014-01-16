;;;;; tré – Copyright (c) 2011–2012,2014 Sven Michael Klose <pixel@copei.de>

(defmacro iterate (iterator step init result &body body)
  (with-gensym next
    `(with (,iterator ,init
            ,next nil)
       (while ,iterator
              ,result
         (= ,next ,step)
         ,@body
         (= ,iterator ,next)))))
