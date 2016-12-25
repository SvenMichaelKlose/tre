(defmacro xchg (a b)
  (with-gensym g
    `(let ,g ,a
	   (= ,a ,b
	   	  ,b ,g))))
