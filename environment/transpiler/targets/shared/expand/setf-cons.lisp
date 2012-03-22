;;;;; tré - Copyright (c) 2012 Sven Michael Klose <pixel@copei.de>

(defun shared-setf-car (val x)
  (with-gensym g
    `(let ,g ,val
       (rplaca ,x ,g)
       ,g)))

(defun shared-setf-cdr (val x)
  (with-gensym g
    `(let ,g ,val
       (rplacd ,x ,g)
       ,g)))
