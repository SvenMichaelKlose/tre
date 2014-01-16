;;;;; tré – Copyright (c) 2012–2014 Sven Michael Klose <pixel@copei.de>

(defmacro with-%= (place value x &body body)
  (with-gensym g
    `(with (,g      ,x
            ,place  (%=-place ,g)
            ,value  (%=-value ,g))
       ,@body)))
