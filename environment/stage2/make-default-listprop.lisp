;;;;; tré – Copyright (c) 2012–2013 Sven Michael Klose <pixel@copei.de>

(defmacro make-default-listprop (x)
  (with-gensym g
    `(let ,g ,x
       (awhen (& (cons? ,g) (cpr ,g))
         (= *default-listprop* !)))))
