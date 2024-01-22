(defmacro optimizer (name &body body)
  `(when x
     (with-cons a d x
       (?
         (named-lambda? a)
           (. (copy-lambda a :body (with-temporary *body* (lambda-body a)
                                     (with-lambda-funinfo a
                                       (,name *body*))))
              (,name d))
         ,@body
         (. a (,name d))))))

(defmacro define-optimizer (name &body body)
  `(fn ,name (x)
     (optimizer ,name
       ,@body)))
