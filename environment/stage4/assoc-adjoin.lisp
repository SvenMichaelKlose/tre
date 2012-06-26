;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defmacro assoc-adjoin (value key place &key (test #'eql))
  (with-gensym (gkey gvalue)
    `(with (,gkey ,key
            ,gvalue ,value)
       (? (assoc-value ,gkey ,place :test ,test)
          (= (assoc-value ,gkey ,place :test ,test) ,gvalue)
          (acons! ,gkey ,gvalue ,place)))))
