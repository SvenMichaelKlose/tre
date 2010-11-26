;;;; TRE environment
;;;; Copyright (c) 2010 Sven Klose <pixel@copei.de>

(defun %funinfo-expr? (x)
  (eq '%funinfo x.))

(defmacro with-lambda-content (x fi vargs vbody &rest body)
  (with-gensym g
    `(with (,g ,x
            ,fi nil
            ,vargs nil
            ,vbody nil)
       (if (%funinfo-expr? ,g)
           (setf ,fi (cadr ,g)
                 ,vargs (caddr ,g)
                 ,vbody (cdddr ,g))
           (setf ,vargs (car ,g)
                 ,vbody (cdr ,g)))
       ,@body)))
