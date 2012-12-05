;;;;; tré – Copyright (c) 2008–2012 Sven Michael Klose <pixel@copei.de>

(defmacro aadjoin! (value key place &key (test #'eql) (to-end? nil))
  (with-gensym (gkey gvalue)
    `(with (,gkey ,key
            ,gvalue ,value)
       (!? (assoc ,gkey ,place :test ,test)
           (= .! ,gvalue)
           ,(? to-end?
               `(append! ,place (list (cons ,gkey ,gvalue)))
               `(acons! ,gkey ,gvalue ,place))))))
