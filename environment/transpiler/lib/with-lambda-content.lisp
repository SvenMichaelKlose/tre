;;;; tré – Copyright (c) 2010,2012 Sven Michael Klose <pixel@copei.de>

(defun %funinfo-expr? (x)
  (eq '%funinfo x.))

(defmacro with-lambda-content (x fi vargs vbody &rest body)
  (with-gensym g
    `(with (,g ,x
            ,fi nil
            ,vargs nil
            ,vbody nil)
       (? (%funinfo-expr? ,g)
          (= ,fi (cadr ,g)
             ,vargs (caddr ,g)
             ,vbody (cdddr ,g))
          (= ,vargs (car ,g)
             ,vbody (cdr ,g)))
       ,@body)))
