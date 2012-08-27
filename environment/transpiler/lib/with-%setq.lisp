;;;;; tré – Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defmacro with-%setq (place value x &rest body)
  (with-gensym g
    `(with (,g ,x
            ,place (%setq-place ,g)
            ,value (%setq-value ,g))
       ,@body)))
