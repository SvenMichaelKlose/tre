;;;;; Caroshi – Copyright (c) 2011–2012 Sven Michael Klose <pixel@copei.de>

(defmacro iterate (iterator step init result &rest body)
  (with-gensym next
    `(with (,iterator ,init
            ,next nil)
       (while ,iterator
              ,result
         (= ,next ,step)
         ,@body
         (= ,iterator ,next)))))
