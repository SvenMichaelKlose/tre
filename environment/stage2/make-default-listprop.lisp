;;;;; tré – Copyright (c) 2012–2014 Sven Michael Klose <pixel@copei.de>

(defmacro make-default-listprop (x)
  (with-gensym g
    `(let ,g ,x
       (awhen (& (cons? ,g) (cpr ,g))
         (= *default-listprop* !)))))

(defmacro listprop-cons (x a d)
  (with-gensym g
    `(progn
       (make-default-listprop ,x)
       (let ,g *default-listprop*
         (rplacp (. ,a ,d) ,g)))))

(defmacro with-default-listprop (x &body body)
  (with-gensym g
    `(let ,g *default-listprop*
       (make-default-listprop ,x)
       (prog1
         (progn ,@body)
         (= *default-listprop* ,g)))))
