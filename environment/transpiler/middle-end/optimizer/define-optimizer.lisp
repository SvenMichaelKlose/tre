; This could as well be a METACODE-WALKER and this had me as soon as I
; forgot about it.  It's gotta go.
(defmacro optimizer (name &body body)
  `(when x
     (with-cons a d x
       (?
         (named-lambda? a)
           (. (copy-lambda a :body (with-temporary *body* (lambda-body a)
                                     (with-lambda-funinfo a
                                       (,name *body*))))
              (,name d))
         (%collection? a)
           (. (append (list '%collection .a.)
                      (@ [. _. (car (,name (list ._)))] ..a))
              (,name d))
         ,@body
         (. a (,name d))))))

(defmacro define-optimizer (name &body body)
  `(fn ,name (x)
     (optimizer ,name
       ,@body)))
